{
  pkgs,
  my,
  lib,
  ...
}: {
  imports = [];

  config = {
    home.packages = with pkgs; [
      amber
      attic-client
      cmake-language-server
      # cura
      discord
      drawio
      dunst
      firefox
      freecad
      gimp
      gopls
      helix
      inkscape
      kicad
      languagetool
      libreoffice
      prettier
      rofi
      scrot
      signal-desktop
      spotify
      stm32cubemx
      teams-for-linux
      texlab
    ];

    programs.waybar.settings.mainBar = {
      temperature = {
        hwmon-path = "/sys/class/hwmon/hwmon6/temp1_input";
      };
    };

    services.kanshi.settings = lib.mkIf my.windowManager.sway.enable [
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = "eDP-1";
            scale = 1.5;
            position = "0,0";
            status = "enable";
          }
        ];
      }

      {
        profile.name = "home";
        profile.outputs = [
          {
            criteria = "Dell Inc. DELL U2414H 9TG465784LAS";
            position = "0,0";
            status = "enable";
          }
          {
            criteria = "eDP-1";
            scale = 1.5;
            position = "0,1080";
            status = "enable";
          }
        ];
      }
    ];
  };
}
