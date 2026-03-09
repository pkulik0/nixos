{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usbhid"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable firmware for WiFi and other hardware
  hardware.enableRedistributableFirmware = true;
}
