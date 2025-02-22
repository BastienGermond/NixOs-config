{...}: {
  services = {
    # immich in nixos-container
    bookstack.enable = false;
    cadvisor.enable = true;
    fail2ban.enable = true;
    forgejo.enable = true;
    matrix-synapse.enable = true;
    minio.enable = true;
    nextcloud.enable = true;
    paperless.enable = true;
    peertube.enable = true;
    promtail.enable = true;
    scrutiny.collector.enable = true;
  };
}
