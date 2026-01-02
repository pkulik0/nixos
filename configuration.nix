{ pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./services.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Filesystem declarations - disko should handle this but we need explicit entries
  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "8425e349";  # Required for ZFS, generated randomly

  swapDevices = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "qurrie";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  users.users.pk = {
    isNormalUser = true;
    description = "pk";
    extraGroups = [ "networkmanager" "wheel" "podman" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3Ipi7wCDAg+CkwYoH2zkPTY/ozhMbZd58g7NCnGSnS"
    ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    htop
    ripgrep
    unzip
    dig
    yq
    jq
  ];
  environment.variables = {
    TERM = "xterm-256color";
    EDITOR = "nvim";
  };

  security.sudo.wheelNeedsPassword = false;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 2222 80 443 ];
    allowedUDPPorts = [ 51820 ];
    interfaces.wg0.allowedTCPPorts = [ 5432 6379 4222 8222 8200 9090 9187 9121 7777 ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = "/root/wireguard-keys/private";

      peers = [
        {
          # pk
          publicKey = "B+xqUQ8pwSLrbNpQ6yJeXnZlzsTZGFj8CPIXMh1s7ik=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1; # For WireGuard
  };

  system.stateVersion = "25.11";
}
