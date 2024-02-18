{
  config,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "hackmd.germond.org" {
  locations."/" = let
    hedgedocHost = config.services.hedgedoc.settings.host;
    hedgedocPort = config.services.hedgedoc.settings.port;
  in {
    proxyPass = "http://${hedgedocHost}:${builtins.toString hedgedocPort}";
  };
}
