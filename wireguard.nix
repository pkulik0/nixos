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
    # Use wl+ for wireless and en+ for ethernet interfaces
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o wl+ -j MASQUERADE
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o en+ -j MASQUERADE
    '';

    # Clean up NAT when interface goes down
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o wl+ -j MASQUERADE || true
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o en+ -j MASQUERADE || true
    '';
  };

  networking.firewall.interfaces.wg0 = {
    allowedTCPPorts = [
      53 # DNS
      config.myconfig.ports.ssh # SSH access through VPN
      config.myconfig.ports.k3s # k3s API server
    ];
    allowedUDPPorts = [
      53 # DNS
    ];
  };
}
