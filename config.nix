{ lib, ... }:

{
  options.myconfig = {
    ports = {
      ssh = lib.mkOption {
        type = lib.types.port;
        default = 2222;
        description = "SSH port";
      };
      wireguard = lib.mkOption {
        type = lib.types.port;
        default = 30050;
        description = "WireGuard port";
      };
      k3s = lib.mkOption {
        type = lib.types.port;
        default = 6443;
        description = "k3s API server port";
      };
    };
    keys = {
      pk = lib.mkOption {
        type = lib.types.str;
        default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3Ipi7wCDAg+CkwYoH2zkPTY/ozhMbZd58g7NCnGSnS";
        description = "pk's SSH public key";
      };
    };
  };
}
