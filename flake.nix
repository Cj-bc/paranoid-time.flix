{
  description = "Simple DateTime library for flix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    utils.url = "github:Cj-bc/my-nix-utils";
    flix.url = "github:Cj-bc/flix.nix";
  };

  outputs = { self, nixpkgs, utils, flix }:
    utils.lib.eachSystems [ "x86_64-linux" "aarch64-linux" ] (system:
      let pkgs = import nixpkgs { system = system; overlays = [ ]; };
      in { 
        packages.${system}.default = pkgs.stdenv.mkDerivation {
          name = "datetime.flix";
          version = "0.1.0";
          src = "src";
          buildInputs = [ flix.packages.${system}.flix_0_73_0 ];
        };

        devShells.${system}.default = pkgs.mkShell {
          packages = [ flix.packages.${system}.flix_0_73_0 ];
        };
      }
    );
}
