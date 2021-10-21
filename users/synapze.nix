{ pkgs, lib, ... }:

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

  xdg.configHome = "/home/synapze/.config";

  xdg.configFile = {
    "git/config".source = ./dotfiles/gitconfig;
    "dunst/dunstrc".source = ./dotfiles/dunstrc;
    "i3/config".source = ./dotfiles/i3;
    "polybar/config".source = ./dotfiles/polybar/config;
    "polybar/launch.sh".source = ./dotfiles/polybar/launch.sh;
    "signature".source = ./dotfiles/signature;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font.size = 8.0;
      debug.log_level = "INFO";
      shell.program = "/usr/bin/env";
      shell.args = [ "zsh" ];
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # enableSyntaxHighlighting = true;
    shellAliases = {
      gs = "git status";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "re5et";
    };
  };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    vimAlias = true;
    extraPackages = with pkgs; [
      tree-sitter
      ctags
    ];

    plugins = with pkgs.vimPlugins; [
      vim-plug
      vim-which-key
      vim-nix
      suda-vim
    ];

    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ./dotfiles/vimrc)
    ];
  };

  programs.rofi = {
    enable = true;
    font = "Terminus (TTF) 12";
  };

  programs.git = {
    enable = false;
    # config = {
    #   init.defaultBranch = "master";

    #   user.email = "bastien.germond@epita.fr";
    #   user.name = "Bastien Germond";
    #   user.signingkey = "030DD35F6457EE71";

    #   commit.verbose = true;
    #   commit.gpgsign = true;

    #   push.followTags = true;

    #   gpg.program = "gpg2";
    # };
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    bat
    binutils
    discord
    dunst
    dunst
    file
    gimp
    gtop
    jq
    scrot
    slack
    libnotify
    rofi
    inkscape
  ];
}
