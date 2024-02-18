{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "git.germond.org" {
  locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://${anemone.ips.vpn.A}:${builtins.toString anemone.ports.gitea}";
  };

  extraConfig = ''
    client_max_body_size 512M;
  '';
}
