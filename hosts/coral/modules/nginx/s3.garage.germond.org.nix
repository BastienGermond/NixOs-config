{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "s3-garage.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;

    extraConfig = ''
      # Disable buffering to a temporary file.
      proxy_max_temp_file_size 0;
    '';

    proxyPass = "http://${anemone.ips.vpn.A}:${builtins.toString anemone.ports.garage-s3}";
  };
}
