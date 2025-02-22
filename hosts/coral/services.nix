{...}: {
  mailserver.enable = true;

  services = {
    atticd.enable = true;
    bind.enable = true;
    fail2ban.enable = true;
    gatus.enable = true;
    grafana.enable = true;
    hedgedoc.enable = true;
    homepage-dashboard.enable = true;
    keycloak.enable = true;
    loki.enable = true;
    nginx.enable = true;
    prometheus.alertmanager.enable = true;
    prometheus.enable = true;
    prometheus.exporters.dmarc.enable = true;
    prometheus.exporters.node.enable = true;
    promtail.enable = true;
    scrutiny.collector.enable = false; # This is a VPS.
    scrutiny.enable = true;
    transfer_sh.enable = true;
    vouch-proxy.enable = true;
  };
}
