{
  description = "Flake with overlay for a custom package";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      overlay = final: prev: {
        htop = prev.htop.overrideAttrs (old: {
          src = ./.;
          patches = [];
          preConfigure = (if old ? preConfigure then old.preConfigure else "") +
            ''
              export CFLAGS="$CFLAGS -I${prev.libnl.dev}/include/libnl3"
            '';
        });
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
      in {
        packages = {
          htop = pkgs.htop;
          default = pkgs.htop;
        };
    }) // {
      overlays.default = overlay;
    };
}
