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
    clipit
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
    libcgroup
    man-pages
    man-pages-posix
    neovim
    networkmanagerapplet
    parted
    pavucontrol
    ripgrep
    thunderbird-91
    tree
    unzip
    wget
    whois
    xsel
    zip
    zsh
  ];
}
