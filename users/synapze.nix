{ pkgs, lib, inputs, ... }:

{
  home.username = "synapze";
  # home.homeDirectory = "/home/synapze";

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
    "polybar/polybar-wireguard.sh".source = ./dotfiles/polybar/polybar-wireguard;
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

    initExtra = ''
      any-nix-shell zsh --info-right | source /dev/stdin
    '';

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.4.0";
          sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
        };
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "re5et";
    };
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    vimAlias = true;
    extraPackages = with pkgs; [
      tree-sitter
      ctags

      # Fzf
      fzf

      # LSP
      pyright
      rnix-lsp
      ccls
      texlab
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

  home.packages = with pkgs; [
    any-nix-shell
    bat
    binutils
    ccls
    clang-tools
    cura
    discord
    docker-buildx
    dunst
    dunst
    file
    freecad
    fzf
    gimp
    gtop
    inkscape
    jq
    kicad-unstable
    languagetool
    libnotify
    libreoffice
    picocom
    rnix-lsp
    rofi
    scrot
    signal-desktop
    slack
    stm32cubemx
    super-slicer
    texlab
  ];
}
