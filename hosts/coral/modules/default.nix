{ config, pkgs, ... }:

{
  imports = [
    ./sops.nix
    ./ssh.nix
    ./packages.nix
    ./nsd.nix
    # ./bind.nix
    ./nginx.nix
    ./wireguard.nix
    ./monitoring.nix
  ];
}
