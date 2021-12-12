{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  fonts.fonts = with pkgs; [
    terminus-nerdfont
    terminus_font_ttf
    termsyn
    font-awesome
    roboto
    noto-fonts
  ];

  environment.systemPackages = with pkgs; [
    adapta-gtk-theme
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
    feh
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
    teamviewer
    thermald
    thunderbird-91
    tree
    unzip
    usbutils
    wget
    whois
    xsel
    zip
    zsh
  ];
}
