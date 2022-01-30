{ pkgs, lib, ... }:

{
  xdg.enable = true;

  home.username = "root";

  xdg.userDirs = {
    download = "\$HOME/Downloads";
    desktop = "\$HOME";
    documents = "\$HOME/Documents";
    music = "\$HOME/Music";
    pictures = "\$HOME/Pictures";
    templates = "\$HOME";
    videos = "\$HOME/Videos";
  };

  xdg.configHome = "/root/.config";

  xdg.configFile = {
    "git/config".source = ./dotfiles/gitconfig;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font.size = 8.0;
      debug.log_level = "INFO";
    };
  };

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

  home.packages = with pkgs; [
    bat
    binutils
    dunst
    file
    jq
    libnotify
    rofi
  ];
}
