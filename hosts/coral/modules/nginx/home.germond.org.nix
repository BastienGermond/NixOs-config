{
  coral,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "home.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://localhost:${builtins.toString coral.ports.homepage-dashboard}";
  };
}
