{ config, pkgs, ... }:

{
  imports = [
    ./ssh.nix
    ./packages.nix
  ];
}
