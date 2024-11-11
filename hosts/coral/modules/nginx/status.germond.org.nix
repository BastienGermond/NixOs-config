{
  config,
  withDefaultConfiguration,
  ...
}: let
  gatusWebCfg = config.services.gatus.settings.web;
in
  withDefaultConfiguration "status.germond.org" {
    locations."/" = {
      proxyPass = "http://${gatusWebCfg.address}:${builtins.toString gatusWebCfg.port}";
      proxyWebsockets = true;
    };
  }
