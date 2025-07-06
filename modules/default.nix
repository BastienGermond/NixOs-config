{...}: {
  imports = [
    # ./dynamic-xrandr.nix
    ./gose.nix
    ./my.nix
    ./nix.nix
    ./postgresql-ciphered-backup.nix
    ./ssh.nix
    ./transfer.sh.nix
    ./vouch-proxy.nix
  ];
}
