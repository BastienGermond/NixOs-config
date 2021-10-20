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
    bind
    brave
    evince
    cryptsetup
    ctags
    curl
    flameshot
    gcc
    git
    gnumake
    gnupg
    gparted
    gzip
    htop
    neovim
    parted
    ripgrep
    thunderbird-91
    tree
    unzip
    wget
    xsel
    zip
    pavucontrol
  ];
}
