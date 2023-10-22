{
  config,
  lib,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  fonts.fonts = with pkgs; [
    fira
    font-awesome
    julia-mono
    noto-fonts
    roboto
    termsyn
    (nerdfonts.override {fonts = ["FiraMono" "FiraCode" "Terminus"];})
  ];

  environment.systemPackages = with pkgs; [
    adapta-gtk-theme
    alacritty
    arandr
    arduino
    aspell
    aspellDicts.en
    aspellDicts.fr
    bind
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
    librewolf-wayland
    matlab
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
