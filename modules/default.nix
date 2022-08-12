{ config, pkgs, ... }:

{
  imports = [
    ./ssh.nix
    ./nix.nix
    ./authentik.nix
  ];
}
