{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "videos.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    # proxyPass = "http://${anemone.ips.vpn.A}:${builtins.toString anemone.ports.peertube}";
    proxyPass = "http://${anemone.ips.vpn.A}";

    extraConfig =
      # nginx
      ''
        client_max_body_size 10G;
      '';
  };
}
