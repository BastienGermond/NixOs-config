{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "immich.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    proxyWebsockets = true;
    proxyPass = "http://${anemone.ips.vpn.A}:${builtins.toString anemone.ports.immich-server}";

    extraConfig = ''
      # set timeout
      proxy_read_timeout 600s;
      proxy_send_timeout 600s;
      send_timeout       600s;

      # allow large file uploads
      client_max_body_size 20G;
    '';
  };
}
