{ config, pkgs, ... }:

{
  imports = [
    ./authentik.nix
    ./gatus.nix
    ./nix.nix
    ./postgresql-ciphered-backup.nix
    ./ssh.nix
    ./transfer.sh.nix
  ];
}
