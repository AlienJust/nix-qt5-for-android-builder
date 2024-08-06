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

    androidPackagesVersions = {
      cmdLineTools = "13.0";
      #cmdLineTools = "10.0";
      platformTools = "35.0.1";
      buildTools = "23.0.0";
      platform = "23";
      ndk = "25.1.8937393";
      #ndk = "21.4.7075529";
      cmake = "3.22.1";
    };

    androidComposition = pkgs.androidenv.composeAndroidPackages (with androidPackagesVersions; {
      cmdLineToolsVersion = cmdLineTools;
      platformToolsVersion = platformTools;
      buildToolsVersions = [buildTools];
      platformVersions = [platform];
      # includeSources = true;
      abiVersions = ["armeabi-v7a" "arm64-v8a" "x86_64"];
      includeNDK = true;
      ndkVersion = ndk;
      cmakeVersions = [cmake];
    });

    androidSdk = androidComposition.androidsdk;
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
          openjdk17
          gradle_6
          androidSdk

          /*
          (with dotnetCorePackages;
            combinePackages [
              sdk_6_0
              sdk_7_0
              sdk_8_0
            ])
          omnisharp-roslyn
          mono
          msbuild
          */
          (pkgs.buildFHSEnv {
            name = "qt5-for-android-builder";
            targetPkgs = pkgs:
              with pkgs;
                [
                  qt5-for-android-builder
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
