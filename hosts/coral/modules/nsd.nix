{ pkgs, config, dns, ... }:

{
  services.nsd = {
    enable = true;
    zones = {
      "synapze.fr" = {
        master = true;
        data = pkgs.lib.readFile ../data/dns/zones/synapze.fr.db;
      };
      "germond.org" = {
        master = true;
        data = pkgs.lib.readFile ../data/dns/zones/germond.org.db;
      };
      "gistre.fr" = {
        master = true;
        data = dns.lib.toString "gistre.fr" (import ../data/dns/zones/gistre.fr.db.nix { inherit dns; });
      };
    };
  };
}
