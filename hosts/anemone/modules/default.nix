{ config, pkgs, ... }:

{
  imports = [
    ./authentik.nix
    ./docker.nix
    ./k3s.nix
    ./minio.nix
    ./monitoring.nix
    ./nextcloud.nix
    ./nfs.nix
    ./packages.nix
    ./paperless.nix
    ./sops.nix
    ./ssh.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
