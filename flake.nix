{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls-overlay = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, rust-overlay, zig-overlay, zls-overlay, disko, ... }:
    {
      nixosConfigurations.qurrie = nixpkgs.lib.nixosSystem {
        modules = [
          { nixpkgs.hostPlatform = "aarch64-linux"; }
          disko.nixosModules.disko
          ./disko.nix
          ./configuration.nix

          ({ ... }: {
            nixpkgs.overlays = [
              rust-overlay.overlays.default
              zig-overlay.overlays.default
            ];
          })

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pk = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit zls-overlay;
            };
          }
        ];
      };
    };
}
