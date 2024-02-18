{
  config,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "t.germond.org" {
  locations."/" = {
    proxyPass = "http://${config.services.transfer_sh.config.listener}";
    extraConfig = ''
      client_max_body_size 5G;
    '';
  };
}
