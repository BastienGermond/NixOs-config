{ config, pkgs, ... }:

{
  imports = [
    ./docker.nix
    ./k3s.nix
    ./packages.nix
    ./ssh.nix
    ./wireguard.nix
    ./zfs.nix
    ./nfs.nix
    ./authentik.nix
  ];
}
