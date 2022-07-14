{ config, pkgs, inputs, ... }:

{
  xdg.enable = true;

  xdg.mime.enable = false;
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
    "git/config".source = ../users/dotfiles/gitconfig;
    "dunst/dunstrc".source = ../users/dotfiles/dunstrc;
    "i3/config".source = ../users/dotfiles/i3;
    "polybar/config".source = ../users/dotfiles/polybar/config;
    "polybar/launch.sh".source = ../users/dotfiles/polybar/launch.sh;
    "polybar/polybar-wireguard.sh".source = ../users/dotfiles/polybar/polybar-wireguard;
    "signature".source = ../users/dotfiles/signature;
    "nvim/lua/plugins.lua".source = ../users/dotfiles/vim/lua/plugins.lua;
  };
}
