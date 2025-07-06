{...}: {
  # You will need to unlock this partition
  boot.initrd.luks.devices.crypted.device = "/dev/disk/by-label/NixOS-Encrypted";

  fileSystems."/" = {
    device = "/dev/disk/by-label/NixOS-Root";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/NixOS-Home";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NixOS-Boot";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  # Swap configuration
  boot.kernel.sysctl = {
    "vm.swappiness" = 99; # Don't use swap unless really necessary
  };

  swapDevices = [
    {
      device = "/dev/disk/by-label/NixOS-Swap";
    }
  ];
}
