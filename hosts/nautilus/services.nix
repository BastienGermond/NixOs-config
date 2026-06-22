{
  pkgs,
  lib,
  ...
}: {
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    cups-filters
    cups-browsed
    hplipWithPlugin
    carps-cups
    gutenprintBin
    cnijfilter2
  ];

  services.libinput.touchpad.accelSpeed = lib.mkForce "1.0";
}
