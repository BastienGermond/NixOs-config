{...}: {
  imports = [
    ./bookstack.nix
    ./docker.nix
    ./fail2ban.nix
    ./gitea.nix
    ./immich.nix
    ./k3s.nix
    ./minio.nix
    ./monitoring.nix
    ./nextcloud.nix
    ./nfs.nix
    ./packages.nix
    ./paperless.nix
    ./peertube.nix
    ./scrutiny.nix
    ./sops.nix
    ./ssh.nix
    ./synapse.nix
    ./wireguard.nix
    ./zfs.nix
  ];
}
