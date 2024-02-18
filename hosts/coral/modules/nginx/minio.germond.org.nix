{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "minio.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://${anemone.ips.vpn.A}:${builtins.toString anemone.ports.minio}";
    proxyWebsockets = true;
  };
}
