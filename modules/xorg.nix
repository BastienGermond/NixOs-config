{
  config,
  pkgs,
  ...
}: {
  services.xserver = {
    enable = true;
    videoDrivers = ["modesetting"];
    # displayManager.autoLogin.enable = true;

    xkb = {
      layout = "us";
      variant = "alt-intl";
    };

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
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        tappingDragLock = false;
      };
      mouse = {
        tapping = false;
        tappingDragLock = false;
      };
    };
  };
}
