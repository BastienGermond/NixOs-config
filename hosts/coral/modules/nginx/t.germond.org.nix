{
  config,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "t.germond.org" {
  locations."/" = {
    proxyPass = "http://${config.services.transfer_sh.config.listener}";
    extraConfig =
      # nginx
      ''
        client_max_body_size ${builtins.toString config.services.transfer_sh.config.max-upload-size}k;
      '';
  };
}
