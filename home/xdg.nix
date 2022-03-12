{config, pkgs, inputs, ...}:

{
  xdg.enable = true;

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
  };
}
