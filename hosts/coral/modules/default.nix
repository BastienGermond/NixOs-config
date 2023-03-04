{ config, pkgs, ... }:

{
  imports = [
    # ./nsd.nix
    ./bind.nix
    ./gatus.nix
    ./hedgedoc.nix
    ./keycloak.nix
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
