rec {
  hosts = {
    coral = {
      ips = {
        public = {
          A = "135.181.36.15";
          AAAA = "";
        };
        vpn = {
          A = "10.100.10.1";
          AAAA = "";
        };
      };
      ports = {
        alert-manager = 9093;
        attic = 8002;
        prometheus = 9001;
        node-exporter = 9002;
        promtail = 3031;
        loki = 3100;
        keycloak = 9042;
        keycloak-management = 9000;
        vault = 8200;
        homepage-dashboard = 8082;
        scrutiny-dashboard = 8001;
      };
      wireguard = {
        wgs0 = {
          ips = ["${hosts.coral.ips.vpn.A}/24"];
          listenPort = 51821;
          privateKeyFile = "/root/.wg/wgs0.pkey";
          # mtu = 1380;

          peers = [
            {
              publicKey = "ptVPzlnSRGpOVrlD/cYhvG/AKEAWe32UaDPAo0ivnG4=";
              allowedIPs = [hosts.anemone.ips.vpn.A];
            }
            {
              publicKey = "hHWuxL+GuQ78uZNcUqTqyTdsCNDXXlsMlxf6IFm5ZUM=";
              allowedIPs = [hosts.synapze-pc.ips.vpn.A];
            }
          ];
        };
      };
    };

    anemone = {
      ips = {
        vpn = {
          A = "10.100.10.2";
          AAAA = "";
        };
      };
      ports = {
        cadvisor = 9004;
        gitea = 9006;
        gitea-ssh = 2222;
        matrix-synapse-monitoring = 9092;
        minio = 9031;
        node-exporter = 9002;
        paperless = 28981;
        peertube = 9010;
        promtail = 3031;
        s3 = 9030;
        garage-s3 = 9032;
        garage-web = 9033;
        systemd-exporter = 9003;
        immich-server = 9012;
        komga = 25600;
        komf = 25601;
        suwayomi = 9080;
      };
      wireguard = {
        wg0 = {
          ips = ["${hosts.anemone.ips.vpn.A}/32"];
          listenPort = 51821;
          privateKeyFile = "/root/.wg/wg0.pkey";
          # mtu = 1380;

          peers = [
            {
              publicKey = "IOXJd4A9NO9JMcRcQRl5QYL8WW0s13+PMnyZVbbr728=";
              allowedIPs = ["10.100.10.0/24"];
              endpoint = "${hosts.coral.ips.public.A}:${builtins.toString hosts.coral.wireguard.wgs0.listenPort}";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };

    nautilus = {
      ips = {
        vpn = {
          A = "10.100.10.3";
          AAAA = "";
        };
      };
      wireguard = {
        wg0 = {
          ips = ["${hosts.nautilus.ips.vpn.A}/32"];
          listenPort = 51821;
          privateKeyFile = "/home/bastien/.wg/wg0.pkey";

          peers = [
            {
              publicKey = "IOXJd4A9NO9JMcRcQRl5QYL8WW0s13+PMnyZVbbr728=";
              allowedIPs = ["10.100.10.0/24"];
              endpoint = "${hosts.coral.ips.public.A}:${builtins.toString hosts.coral.wireguard.wgs0.listenPort}";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
}
