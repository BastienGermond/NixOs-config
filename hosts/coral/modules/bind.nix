{
  pkgs,
  config,
  dns,
  ...
}: let
  writeZone = name:
    pkgs.writeTextFile {
      name = "${name}.zone";
      text = dns.lib.toString name (import ../data/dns/zones/${name}.db.nix {inherit dns;});
    };
in {
  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];

  services.bind = {
    enable = true;
    enableGistreFr = true;
    extraOptions = ''
      dnssec-validation auto;

      allow-recursion { cachenetworks; 10.100.10.0/24; };
    '';
    extraConfig = ''
      include "${config.sops.secrets.bindDnsKey.path}";

      logging {
        channel dnssec_log {
          file "/var/log/named/dnssec.log";
          severity debug 3;
        };
        category dnssec { dnssec_log; };
      };
    '';
    zones = {
      "synapze.fr" = {
        master = true;
        file = writeZone "synapze.fr";
      };
      "germond.org" = {
        master = true;
        file = writeZone "germond.org";
        extraConfig = ''
          dnssec-policy default;

          journal "/run/named/germond.org.zone.jnl";
          allow-update { key rfc2136key.germond.org.; };
        '';
      };
      "gistre.fr".master = true;
    };
  };
}
