{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
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
