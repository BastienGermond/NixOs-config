{ config, pkgs, inputs, ... }:

{
  xdg.enable = true;

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = [ "evince.desktop" ];
      "text/html" = [ "librewolf.desktop" ];
      "x-scheme-handler/http" = [ "librewolf.desktop" ];
      "x-scheme-handler/https" = [ "librewolf.desktop" ];
      "x-scheme-handler/about" = [ "librewolf.desktop" ];
      "x-scheme-handler/unknown" = [ "librewolf.desktop" ];
    };
    defaultApplications = {
      "application/pdf" = "evince.desktop";
      "text/html" = [ "librewolf.desktop" ];
      "x-scheme-handler/http" = [ "librewolf.desktop" ];
      "x-scheme-handler/https" = [ "librewolf.desktop" ];
      "x-scheme-handler/about" = [ "librewolf.desktop" ];
      "x-scheme-handler/unknown" = [ "librewolf.desktop" ];
    };
  };

  xdg.userDirs = {
    download = "\$HOME/Downloads";
    desktop = "\$HOME";
    documents = "\$HOME/Documents";
    music = "\$HOME/Music";
    pictures = "\$HOME/Pictures";
    templates = "\$HOME";
    videos = "\$HOME/Videos";
  };

  xdg.configFile = {
    "git/config".source = ../dotfiles/gitconfig;
    "dunst/dunstrc".source = ../dotfiles/dunstrc;
    "i3/config".source = ../dotfiles/i3;
    "polybar/config".source = ../dotfiles/polybar/config;
    "polybar/launch.sh".source = ../dotfiles/polybar/launch.sh;
    "polybar/polybar-wireguard.sh".source = ../dotfiles/polybar/polybar-wireguard;
    "signature".source = ../dotfiles/signature;
    "nvim/lua/plugins.lua".source = ../dotfiles/vim/lua/plugins.lua;
  };
}
