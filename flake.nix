{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      flake-utils,
      naersk,
      nixpkgs,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        naersk' = pkgs.callPackage naersk { };

      in
      rec {
        bevyDeps = with pkgs; [
          pkg-config
          alsa-lib
          libudev-zero
        ];

        # For `nix build` & `nix run`:
        defaultPackage = naersk'.buildPackage {
          src = ./.;

          nativeBuildInputs = bevyDeps;
        };

        # For `nix develop`:
        devShell = pkgs.mkShell {
          nativeBuildInputs =
            with pkgs;
            [
              # Rust
              rustc
              cargo

              # Developer tooling
              clippy
              rust-analyzer
              rustfmt
            ]
            ++ bevyDeps;
        };
      }
    );
}
