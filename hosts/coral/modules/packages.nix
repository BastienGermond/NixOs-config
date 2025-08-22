{pkgs, ...}: {
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
    parted
    ripgrep
    tmux
    tree
    unzip
    wget
    whois
    zip
    zsh
  ];
}
