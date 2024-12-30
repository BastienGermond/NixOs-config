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

  germondOrgZone = writeZone "germond.org";
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
        file = "/etc/bind/germond.org.zone";
        extraConfig = ''
          inline-signing yes;
          dnssec-policy default;

          journal "${config.services.bind.directory}/germond.org.zone.signed.jnl";

          allow-update { key rfc2136key.germond.org.; };
        '';
      };
      "gistre.fr".master = true;
    };
  };

  systemd.services."bind-pre-start" = {
    enable = true;

    wantedBy = ["bind.service"];
    requiredBy = ["bind.service"];

    script = ''
      mkdir -m 0755 -p /etc/bind
      chown named:named -R /etc/bind

      # Copy germond.org zone in /etc/bind
      ${pkgs.coreutils}/bin/cp ${germondOrgZone} /etc/bind/germond.org.zone
      chown named:named /etc/bind/germond.org.zone
    '';
  };

  systemd.services."mx-germond-org-dane-tsla-updater" = {
    enable = true;

    path = with pkgs; [openssl hash-slinger];

    script = ''
      set -e -o pipefail

      CERTIFICATE_FOLDER=/var/lib/acme/germond.org

      tlsa -c --port 25 --usage 3 --selector 1 --certificate $CERTIFICATE_FOLDER/cert.pem mx.germond.org > $CERTIFICATE_FOLDER/dane.line
    '';

    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    serviceConfig = {
      Type = "oneshot";
      User = "acme";
      Group = "named";
    };
  };
}
