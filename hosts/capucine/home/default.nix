{pkgs, ...}: {
  imports = [
  ];

  config = {
    home.packages = with pkgs; [
      amber
      attic-client
      cmake-language-server
      # cura
      discord
      docker-buildx
      drawio
      dunst
      firefox
      freecad
      gimp
      glab
      gopls
      helix
      inkscape
      kicad
      languagetool
      libreoffice
      eslint
      prettier
      typescript-language-server
      rofi
      scrot
      signal-desktop
      slack
      # spotibar
      spotify
      stm32cubemx
      # super-slicer
      teams-for-linux
      texlab
    ];
  };
}
