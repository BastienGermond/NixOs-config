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
    k3s
    man-pages
    man-pages-posix
    neovim
    parted
    ripgrep
    tmux
    tree
    unzip
    wget
    whois
    zip
    zsh
    zfs
  ];
}
