{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "s3.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://${anemone.ips.vpn.A}:${builtins.toString anemone.ports.s3}";
    extraConfig = ''
      client_max_body_size 10G;
    '';
  };
}
