{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
    useGlamor = true;
    layout = "us";
    xkbVariant = "alt-intl";
    displayManager.autoLogin.enable = true;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3lock
        polybarFull
        at-spi2-core
      ];
    };

    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };
}
