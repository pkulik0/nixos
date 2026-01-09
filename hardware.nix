{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.swraid.enable = true;
  boot.swraid.mdadmConf = ''
    MAILADDR root
  '';

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "8425e349"; # Required for ZFS

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    devices = [ "nodev" ];
    mirroredBoots = [
      { devices = [ "/dev/nvme0n1" ]; path = "/boot"; }
      { devices = [ "/dev/nvme1n1" ]; path = "/boot"; }
    ];
  };
}
