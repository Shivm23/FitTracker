{
  description = "Flutter 3.19.x environment with Android SDK";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        androidPkgs = (pkgs.androidenv.composeAndroidPackages {
          platformVersions = [ "27" "29" "31" "33" "34" ];
          buildToolsVersions = [ "30.0.3" ];
          includeEmulator = true;
          includeSystemImages = true;
        });

        emulator = pkgs.androidenv.emulateApp {
          name = "flutter_emu";
          platformVersion = "27";
          abiVersion = "x86";
          systemImageType = "google_apis_playstore";
          deviceName = "pixel";
        };

      in {
        devShells.default = pkgs.mkShell {
          ANDROID_SDK_ROOT = "${androidPkgs.androidsdk}/libexec/android-sdk";
          buildInputs = [
            pkgs.flutter
            pkgs.jdk17
            androidPkgs.androidsdk
            emulator
          ];
        };
      });
}
