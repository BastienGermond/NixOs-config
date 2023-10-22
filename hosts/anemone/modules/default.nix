{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./authentik.nix
    ./bookstack.nix
    ./docker.nix
    ./fail2ban.nix
    ./gitea.nix
    ./k3s.nix
    ./minio.nix
    ./monitoring.nix
    ./nextcloud.nix
    ./nfs.nix
    ./packages.nix
    ./paperless.nix
    ./sops.nix
    ./ssh.nix
    ./synapse.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
