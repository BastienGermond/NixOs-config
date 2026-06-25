{pkgs, ...}: {
  services.udev = {
    extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374a", \
      MODE:="0666", \
      SYMLINK+="stlinkv2-1_%n"

      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
          MODE:="0666", \
          SYMLINK+="stlinkv2-1_%n"

      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", \
          MODE:="0666", \
          SYMLINK+="stlinkv2-1_%n"
    '';
    packages = [
      pkgs.yubikey-personalization
      pkgs.platformio
      pkgs.openocd
      pkgs.qmk-udev-rules
    ];
  };

  services.thermald.enable = true;

  services.teamviewer.enable = true;

  services.printing = {
    enable = true;
    drivers = [pkgs.hplip pkgs.hplipWithPlugin];
  };

  # Fix from https://wiki.archlinux.org/title/Lenovo_ThinkPad_T14_(AMD)_Gen_3#Suspend/Hibernate
  systemd.services.ath11k-suspend = {
    enable = true;
    wantedBy = ["sleep.target"];
    before = ["sleep.target"];
    description = "Suspend: rmmod ath11k_pci";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${pkgs.kmod}/bin/rmmod ath11k_pci'';
    };
  };
  systemd.services.ath11k-resume = {
    enable = true;
    wantedBy = ["suspend.target" "suspend-then-hibernate.target" "hibernate.target" "hybrid-sleep.target"];
    after = ["suspend.target" "suspend-then-hibernate.target" "hibernate.target" "hybrid-sleep.target"];
    description = "Resume: modprobe ath11k_pci";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${pkgs.kmod}/bin/modprobe ath11k_pci'';
    };
  };
}
