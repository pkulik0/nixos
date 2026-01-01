{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, rust-overlay, ... }:
    {
      nixosConfigurations.ankara = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        modules = [
          ./configuration.nix

          ({ ... }: {
            nixpkgs.overlays = [ rust-overlay.overlays.default ];
          })

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pk = import ./home.nix;
          }
        ];
      };
    };
}
