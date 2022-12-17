{ config, pkgs, ... }:

{
  imports = [
    ./authentik.nix
    ./gatus.nix
    ./nix.nix
    ./ssh.nix
    ./transfer.sh.nix
  ];
}
