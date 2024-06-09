{infra, ...}: let
  coral = infra.hosts.coral;
in {
  services.scrutiny.collector = {
    enable = true;
    settings = {
      host.id = "anemone";
      api.endpoint = "http://${coral.ips.vpn.A}:${builtins.toString coral.ports.scrutiny-dashboard}";
    };
  };
}
