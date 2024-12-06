{
  config,
  lib,
  pkgs,
  ...
}: {
  fonts.packages = with pkgs; [
    fira
    font-awesome
    julia-mono
    noto-fonts
    roboto
    termsyn
    (nerdfonts.override {fonts = ["FiraMono" "FiraCode" "Terminus"];})
    liberation_ttf
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
    dconf-editor
    evince
    feh
    flameshot
    fritzing
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
    librewolf-wayland
    man-pages
    man-pages-posix
    matlab
    nautilus
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
