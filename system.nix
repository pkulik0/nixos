{ pkgs, config, ... }:

{
  imports = [
    ./config.nix
    ./hardware.nix
    ./sops.nix
    ./wifi.nix
    ./wireguard.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    download-buffer-size = 512 * 1024 * 1024; # 512 MiB
  };

  networking.hostName = "mini";
  networking.useDHCP = true; # enables DHCP on all interfaces (including ethernet)

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  users.users.pk = {
    isNormalUser = true;
    description = "pk";
    initialHashedPassword = "$6$SIJ1Bhz1/oWSdCQW$A1T2Sg7uvuduYOXbjiDw8T88Bs/RoXOfH7TNjT/.LGG7AjH7oWr9c.D1Dk7BIT68YaYyvVGSsDuQJXNoJa5E.1";
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      config.myconfig.keys.pk
    ];
    shell = pkgs.zsh;
  };
  security.sudo.wheelNeedsPassword = false;

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
    htop
    ripgrep
    unzip
    dig
    yq
    jq
    icu
  ];
  environment.variables.TERM = "xterm-256color";

  virtualisation.docker = {
    enable = true;
  };

  services.openssh = {
    enable = true;
    ports = [ config.myconfig.ports.ssh ];
    listenAddresses = [
      {
        addr = "0.0.0.0";
        port = config.myconfig.ports.ssh;
      }
      {
        addr = "10.100.0.1";
        port = 22;
      }
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      listen-address = [
        "127.0.0.1"
        "10.100.0.1"
      ];
      bind-interfaces = true;
      server = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s-token.path;
    extraFlags = toString [
      "--tls-san"
      "10.100.0.1"
    ];
  };

  networking.firewall = {
    allowedUDPPorts = [ config.myconfig.ports.wireguard ];
    allowedTCPPorts = [ config.myconfig.ports.ssh ];
  };

  system.stateVersion = "25.11";
}
