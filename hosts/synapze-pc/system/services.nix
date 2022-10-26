{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];

  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      i3lock
      polybarFull
      at-spi2-core
    ];
  };

  services.xserver.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "alt-intl";

  services.xserver.displayManager.autoLogin.enable = true;

  # Required to use smart card mode (CCID)
  services.pcscd.enable = true;

  # Use to update Dell XPS 13 firmware
  services.fwupd.enable = true;

  services.actkbd = {
    enable = true;
    bindings = [
      # Brightness keys
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    ];
  };

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
    packages = [ pkgs.yubikey-personalization pkgs.platformio pkgs.openocd pkgs.android-udev-rules ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.thermald.enable = true;

  services.teamviewer.enable = true;

  # Enable for Nautilus https://nixos.wiki/wiki/Nautilus
  services.gvfs.enable = true;

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ hplipWithPlugin canon-cups-ufr2 carps-cups cups-bjnp gutenprintBin cnijfilter2 ];
}
