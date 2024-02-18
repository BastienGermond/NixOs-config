{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "docs.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://${anemone.ips.vpn.A}";
  };
}
