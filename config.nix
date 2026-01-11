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
    };
  };
}
