{ config, pkgs, ... }:

{
  imports = [
    # ./nsd.nix
    ./bind.nix
    ./gatus.nix
    ./monitoring.nix
    ./nginx.nix
    ./packages.nix
    ./sops.nix
    ./ssh.nix
    ./wireguard.nix
  ];
}
