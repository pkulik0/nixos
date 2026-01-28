{ config, ... }:

{
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s-token.path;
  };

  networking.firewall.allowedTCPPorts = [ 6443 ];
}
