{
  description = "Flake to build Luna";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    luna-src = {
      url = "github:ndless-nspire/Luna";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      luna-src,
    }:
    let
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.stdenv.mkDerivation {
          pname = "luna";
          version = "git";

          src = luna-src;

          nativeBuildInputs = [ pkgs.gnumake ];
          buildInputs = [ pkgs.zlib ];

          buildPhase = ''
            make
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            make install PREFIX=$out/bin
            runHook postInstall
          '';
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [ self.packages.${pkgs.system}.default ];

          buildInputs = [
            pkgs.firebird-emu
          ];
        };
      });
    };
}
