{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
  };

  outputs = { 
    self, nixpkgs, nixos-wsl
  }: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      goblin_wsl = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/goblin_wsl/configuration.nix
          nixos-wsl.nixosModules.wsl
        ]
      };
    };

  };
}
