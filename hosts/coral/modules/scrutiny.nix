{infra, ...}: let
  coral = infra.hosts.coral;
in {
  services.scrutiny = {
    collector.enable = false;
    openFirewall = true;
    influxdb.enable = true;
    settings = {
      web = {
        listen = {
          host = coral.ips.vpn.A;
          port = coral.ports.scrutiny-dashboard;
        };
      };
    };
  };
}
