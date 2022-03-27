{ config, pkgs, ... }:

{
  imports = [
    ./ssh.nix
    ./packages.nix
    ./wireguard.nix
    ./docker.nix
  ];
}
