{
  config,
  pkgs,
  ...
}: {
  imports = [
    # ./gatus.nix
    ./gose.nix
    ./nix.nix
    ./postgresql-ciphered-backup.nix
    ./ssh.nix
    ./transfer.sh.nix
    ./vouch-proxy.nix
  ];
}
