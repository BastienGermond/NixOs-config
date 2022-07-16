{ pkgs, config, dns, ... }:

{
  services.nsd = {
    enable = true;
    verbosity = 3;
    interfaces = [ "0.0.0.0" ];
    zones = {
      "synapze.fr" = {
        data = dns.lib.toString "synapze.fr" (import ../data/dns/zones/synapze.fr.db.nix { inherit dns; });
      };
      "germond.org" = {
        data = dns.lib.toString "germond.org" (import ../data/dns/zones/germond.org.db.nix { inherit dns; });
      };
      "gistre.fr" = {
        data = dns.lib.toString "gistre.fr" (import ../data/dns/zones/gistre.fr.db.nix { inherit dns; });
      };
    };
  };
}
