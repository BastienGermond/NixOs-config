{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  fonts.fonts = with pkgs; [
    fira
    fira-code
    fira-mono
    font-awesome
    julia-mono
    noto-fonts
    roboto
    terminus-nerdfont
    terminus_font_ttf
    termsyn
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
    fritzing
    gcc
    git
    gnome.dconf-editor
    gnome.nautilus
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
    nixpkgs-fmt
    parted
    pavucontrol
    ripgrep
    teamviewer
    thermald
    thunderbird
    tree
    unzip
    usbutils
    wget
    whois
    xsane
    xsel
    zip
    zsh
  ];
}
