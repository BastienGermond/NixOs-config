{ config, pkgs, ... }:

{
  imports = [
    ./ssh.nix
    ./packages.nix
    ./nsd.nix
    # ./bind.nix
    ./nginx.nix
    ./wireguard.nix
  ];
}
