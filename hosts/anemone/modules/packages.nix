{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    alacritty
    bind
    ctags
    curl
    git
    gnupg
    gparted
    gzip
    htop
    man-pages
    man-pages-posix
    neovim
    parted
    ripgrep
    tree
    unzip
    wget
    whois
    zip
    zsh
  ];
}
