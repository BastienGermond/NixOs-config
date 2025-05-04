{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "komf.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://${anemone.ips.vpn.A}:${builtins.toString anemone.ports.komf}";
  };
}
