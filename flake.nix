{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mistral = {
      url = "github:mistralai/mistral-vibe";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      rust-overlay,
      zig-overlay,
      zls-overlay,
      disko,
      sops-nix,
      mistral,
      ...
    }:
    {
      nixosConfigurations.kulik = nixpkgs.lib.nixosSystem {
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./disko.nix
          ./system.nix

          {
            nixpkgs.overlays = [
              rust-overlay.overlays.default
              zig-overlay.overlays.default
              (final: prev: {
                zls = zls-overlay.packages.${prev.stdenv.hostPlatform.system}.default;
                unstable = import nixpkgs-unstable {
                  system = prev.stdenv.hostPlatform.system;
                  config.allowUnfree = true;
                };
              })
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit mistral; };
            home-manager.users.pk = import ./home;
            home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
          }
        ];
      };
    };
}
