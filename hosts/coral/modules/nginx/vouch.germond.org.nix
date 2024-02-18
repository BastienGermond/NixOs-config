{withDefaultConfiguration, ...}:
withDefaultConfiguration "vouch.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://127.0.0.1:9090";
  };
}
