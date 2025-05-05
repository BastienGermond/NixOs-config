{...}: {
  imports = [
    ./bookstack.nix
    ./docker.nix
    ./fail2ban.nix
    ./garage.nix
    ./gitea.nix
    ./immich.nix
    ./k3s.nix
    ./manga/komf.nix
    ./manga/komga.nix
    ./manga/suwayomi.nix
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
