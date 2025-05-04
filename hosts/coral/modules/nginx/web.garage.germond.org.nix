{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "web-garage.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;

    proxyPass = "http://${anemone.ips.vpn.A}:${builtins.toString anemone.ports.garage-web}";
  };
}
