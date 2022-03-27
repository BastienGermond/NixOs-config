{ config, pkgs, ... }:

{
  imports = [
    ./ssh.nix
    ./packages.nix
    ./bind.nix
    ./nginx.nix
    ./wireguard.nix
  ];
}
