# NixOS

This repository contains my personal NixOS configuration.

## Installation

1. Boot from NixOS installer ISO
2. Run: `sudo nix -–extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- --mode disko ./disko.nix`
3. Install: `sudo nixos-install --flake .#qurrie`

