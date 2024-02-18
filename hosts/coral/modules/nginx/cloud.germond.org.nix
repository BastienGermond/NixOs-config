{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "cloud.germond.org" {
  locations."/" = {
    proxyPass = "http://${anemone.ips.vpn.A}/";
    proxyWebsockets = true;
    extraConfig = ''
      client_max_body_size 10G;
    '';
  };
}
