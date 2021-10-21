{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  fonts.fonts = with pkgs; [
    terminus-nerdfont
    terminus_font_ttf
    termsyn
    font-awesome
  ];

  environment.systemPackages = with pkgs; [
    alacritty
    arandr
    aspell
    aspellDicts.en
    aspellDicts.fr
    bind
    brave
    cryptsetup
    ctags
    curl
    evince
    flameshot
    gcc
    git
    gnumake
    gnupg
    gparted
    gzip
    htop
    iftop
    killall
    neovim
    networkmanagerapplet
    parted
    pavucontrol
    ripgrep
    thunderbird-91
    tree
    unzip
    wget
    xsel
    zip
    zsh
  ];
}
