{pkgs, ...}: {
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
  };
}
