{
  coral,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "cache.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://127.0.0.1:${builtins.toString coral.ports.attic}";
    extraConfig = ''
      client_max_body_size 10G;
    '';
  };
}

