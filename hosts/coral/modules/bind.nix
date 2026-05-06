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

  systemd.services.bind.serviceConfig.StateDirectory = "named";

  services.bind = {
    checkConfig = false;
    extraOptions = ''
      dnssec-validation auto;

      allow-recursion { cachenetworks; 10.100.10.0/24; };
    '';
    extraConfig = ''
      # This file is overwritten by bind-pre-start with the sops path.
      include "/etc/bind/local-keys.conf";

      # logging {
      #   channel dnssec_log {
      #     file "/var/log/named/dnssec.log";
      #     severity debug 3;
      #   };
      #   category dnssec { dnssec_log; };
      # };
    '';
    directory = "/var/lib/named";
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
      # "gistre.fr".master = false;
    };
  };

  # Placeholder for named-checkconf
  environment.etc."bind/local-keys.conf".text = "";

  systemd.services."bind-pre-start" = {
    enable = config.services.bind.enable;

    wantedBy = ["bind.service"];
    requiredBy = ["bind.service"];
    restartTriggers = [germondOrgZone];

    script = ''
      mkdir -m 0755 -p /etc/bind
      chown named:named -R /etc/bind

      # Copy germond.org zone in /etc/bind
      ${pkgs.coreutils}/bin/cp ${germondOrgZone} /etc/bind/germond.org.zone
      chown named:named /etc/bind/germond.org.zone

      # Overwrite the file with sops path
      cat > /etc/bind/local-keys.conf <<EOF
      include "${config.sops.secrets.bindDnsKey.path}";
      EOF

      chown named:named /etc/bind/local-keys.conf
      chmod 0640 /etc/bind/local-keys.conf
    '';
  };

  systemd.services."mx-germond-org-dane-tsla-updater" = {
    enable = false; # FIXME: It's buggy for now. config.services.bind.enable;

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
