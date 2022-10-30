{ pkgs, config, dns, ... }:

let
  writeZone = name: pkgs.writeTextFile {
    name = "${name}.zone";
    text = dns.lib.toString name (import ../data/dns/zones/${name}.db.nix { inherit dns; });
  };
in
{
  services.bind = {
    enable = true;
    enableGistreFr = true;
    extraConfig = ''
      include "${config.sops.secrets.bindDnsKey.path}";
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
          journal "/run/named/germond.org.zone.jnl";
          allow-update { key rfc2136key.germond.org.; };
        '';
      };
      "gistre.fr".master = true;
    };
  };
}
