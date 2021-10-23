{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.useGlamor = true;

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

  # Yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # Required to use smart card mode (CCID)
  services.pcscd.enable = true;

  services.actkbd = {
    enable = true;
    bindings = [
      # Brightness keys
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}
