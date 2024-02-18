{
  config,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "grafana.germond.org" {
  root = config.services.grafana.settings.server.static_root_path;

  locations."/".tryFiles = "$uri @grafana";

  locations."@grafana" = {
    proxyPass = "http://grafana";
    proxyWebsockets = true;
  };
}
