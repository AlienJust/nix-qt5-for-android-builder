{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };

    qt5-for-android-builder = pkgs.callPackage ./default.nix {};
  in {
    packages.x86_64-linux = {
      inherit qt5-for-android-builder;
    };
    packages.x86_64-linux.default = qt5-for-android-builder;

    devShells.x86_64-linux = {
      default = pkgs.mkShell {
        packages = with pkgs; [
          #dotnet-sdk_6
          #dotnet-sdk_7
          #dotnet-sdk_8
          qt5-for-android-builder

          (with dotnetCorePackages;
            combinePackages [
              sdk_6_0
              sdk_7_0
              sdk_8_0
            ])
          omnisharp-roslyn
          mono
          msbuild
          (pkgs.buildFHSEnv {
            name = "avalonia-fhs-shell";
            targetPkgs = pkgs:
              with pkgs;
                [
                  udev
                  alsa-lib
                  fontconfig
                  glew
                ]
                ++ (with pkgs.xorg; [
                  # Avalonia UI
                  libX11
                  libICE
                  libSM
                  libXi
                  libXcursor
                  libXext
                  libXrandr
                ]);
            #runScript = "zsh"; # same colors scheme of zsh confusing me
          })
        ];
      };
    };
    # // { inherit qt5-for-android-builder; }
  };
}
