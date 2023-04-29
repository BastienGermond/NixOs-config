{ config, pkgs, ... }:

{
  imports = [
    ./rofi.nix
    ./terminal.nix
    ./helix.nix
  ];

  config = {
    home.packages = with pkgs;
      [
        cmake-language-server
        cura
        discord
        docker-buildx
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
        nodePackages.eslint
        nodePackages.prettier
        nodePackages.typescript-language-server
        rofi
        scrot
        signal-desktop
        slack
        spotibar
        spotify
        stm32cubemx
        super-slicer
        teams
        texlab
      ];

    xdg.configFile = {
      "dunst/dunstrc".source = ../../../dotfiles/dunstrc;
      "polybar/config".source = ../../../dotfiles/polybar/config;
      "polybar/launch.sh".source = ../../../dotfiles/polybar/launch.sh;
      "polybar/polybar-wireguard.sh".source = ../../../dotfiles/polybar/polybar-wireguard;
    };
  };
}
