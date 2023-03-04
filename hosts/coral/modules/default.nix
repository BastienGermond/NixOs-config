{ config, pkgs, ... }:

{
  imports = [
    # ./nsd.nix
    ./bind.nix
    ./gatus.nix
    ./mailserver.nix
    ./monitoring.nix
    ./nginx.nix
    ./packages.nix
    ./sops.nix
    ./ssh.nix
    ./transfer.sh.nix
    ./wireguard.nix
  ];
}
