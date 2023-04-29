{ config, pkgs, ... }:

{
  imports = [
    ./authentik.nix
    ./gatus.nix
    ./gose.nix
    ./nix.nix
    ./postgresql-ciphered-backup.nix
    ./ssh.nix
    ./transfer.sh.nix
  ];
}
