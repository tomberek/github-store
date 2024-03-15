{
  nixConfig.extra-substituters = ["https://github.com/tomberek/github-store/releases/latest/download/"];

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
  outputs = { self, nixpkgs, }: {

    packages = builtins.mapAttrs (system: pkgs: {
      default = pkgs.callPackage ./default.nix {};
    }) nixpkgs.legacyPackages;

    apps = builtins.mapAttrs (system: pkgs: {
      copy-to-gh = {
        type = "app";
        program = (pkgs.writeShellApplication {
          name = "upload-cache";
          runtimeInputs = with pkgs; [ gnused github-cli findutils ];
          text = ''
            nix build ${self.packages.${system}.default}
            mkdir -p "$PWD/.store"
            nix copy --to "file://$PWD/.store" ${self.packages.${system}.default}
            find .store -iname "*.narinfo" -exec sed -i 's#URL: nar/#URL: #' {} +
            git tag "$1" || true
            gh release create --target master "$1" || true
            gh release upload --clobber "$1" .store/*.narinfo .store/nar/* .store/nix-cache-info
            gh release list
          '';
        })+"/bin/upload-cache";
      };
    }) nixpkgs.legacyPackages;
  };
}
