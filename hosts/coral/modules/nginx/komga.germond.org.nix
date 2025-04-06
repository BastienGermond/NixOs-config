{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "komga.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://${anemone.ips.vpn.A}:${builtins.toString anemone.ports.komga}";
  };
}
