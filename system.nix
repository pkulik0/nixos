{ pkgs, config, ... }:

{
  imports = [
    ./config.nix
    ./hardware.nix
    ./sops.nix
    ./wireguard.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    download-buffer-size = 512 * 1024 * 1024; # 512 MiB
  };

  networking.hostName = "kulik";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  users.users.pk = {
    isNormalUser = true;
    description = "pk";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
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

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  services.openssh = {
    enable = true;
    ports = [ config.myconfig.ports.ssh ];
    listenAddresses = [
      { addr = "0.0.0.0"; port = config.myconfig.ports.ssh; }
      { addr = "10.100.0.1"; port = 22; }
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ config.myconfig.ports.wireguard ];
    allowedTCPPorts = [ config.myconfig.ports.ssh ];
  };

  system.stateVersion = "25.11";
}