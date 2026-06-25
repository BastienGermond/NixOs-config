{
  pkgs,
  lib,
  my,
  ...
}: {
  imports = [
    ./kanshi.nix
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
      signal-desktop
      slack
      # spotibar
      spotify
      stm32cubemx
      # super-slicer
      teams-for-linux
      texlab
    ];

    wayland.windowManager.sway.config.input."type:touchpad".pointer_accel = lib.mkForce "0.70";
  };
}
