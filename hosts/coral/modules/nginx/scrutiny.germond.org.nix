{
  config,
  withDefaultConfiguration,
  ...
}: let
  scrutinyCfg = config.services.scrutiny.settings;
in
  withDefaultConfiguration "scrutiny.germond.org" {
    locations."/" = {
      proxyPass = "http://${scrutinyCfg.web.listen.host}:${builtins.toString scrutinyCfg.web.listen.port}";
      proxyWebsockets = true;
    };
  }
