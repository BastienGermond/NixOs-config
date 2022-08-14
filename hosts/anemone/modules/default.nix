{ config, pkgs, ... }:

{
  imports = [
    ./sops.nix
    ./docker.nix
    ./k3s.nix
    ./packages.nix
    ./ssh.nix
    ./wireguard.nix
    ./zfs.nix
    ./nfs.nix
    ./nextcloud.nix
    ./monitoring.nix
  ];
}
