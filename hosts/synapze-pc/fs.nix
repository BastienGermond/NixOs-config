{ ... }:

{
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/f6f82b66-c89a-40a0-83c6-923cc95753e7";
      fsType = "ext4";
    };

  # You will need to unlock this partition
  boot.initrd.luks.devices.crypted.device = "/dev/disk/by-uuid/4f66e325-a9fc-4c1a-8ac1-8e425fe125c0";

  fileSystems."/home" =
    {
      device = "/dev/mapper/crypted";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/7B64-9AC7";
      fsType = "vfat";
    };

  # Swap configuration
  boot.kernel.sysctl = {
    "vm.swappiness" = 99; # Don't use swap unless really necessary
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/0fc371fc-423b-4cc7-82c0-29e4bd54be56";
    }
  ];

}
