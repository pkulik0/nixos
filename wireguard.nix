{ config, pkgs, ... }:

{
  # Enable IP forwarding for VPN
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = config.myconfig.ports.wireguard;

    privateKeyFile = config.sops.secrets.wireguard-private-key.path;

    peers = [
      {
        publicKey = "jTO9rESBPsKPACyzXSTkTK7WxnPGx4aWdq7ddmNebgQ=";
        presharedKey = "IRf7sXUYElonn29xoz/PsVommmEzjhDInYw0XuBMUfU=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];

    # Set up NAT after the interface is created
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eno1 -j MASQUERADE
    '';

    # Clean up NAT when interface goes down
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eno1 -j MASQUERADE || true
    '';
  };

  networking.firewall = {
    interfaces.wg0.allowedTCPPorts = [
      config.myconfig.ports.ssh  # SSH access through VPN (port 2222)
    ];
  };
}
