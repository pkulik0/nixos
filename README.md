# NixOS

Personal NixOS configuration with GitLab, Grafana, Vault, and WireGuard VPN.

## Deployment

```bash

# Run 
nix run github:nix-community/nixos-anywhere -- --flake .#kulik \
                                               --extra-files ./extra-files \
                                               --build-on-remote \
                                               --target-host <user>@<ip>
```

## Structure

- `flake.nix`: Inputs and system configuration
- `system.nix`: Base system, users, SSH
- `services.nix`: All service configurations
- `sops.nix`: SOPS secret mappings
- `wireguard.nix`: VPN and firewall rules
- `disko.nix`: Disk partitioning (RAID1 + ZFS)
- `hardware.nix`: Hardware-specific config
- `home/`: Home-manager configuration
