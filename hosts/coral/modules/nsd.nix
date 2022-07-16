{ pkgs, config, dns, ... }:

{
  services.nsd = {
    enable = true;
    verbosity = 3;
    interfaces = [ "0.0.0.0" ];
    zones = {
      "synapze.fr" = {
        data = pkgs.lib.readFile ../data/dns/zones/synapze.fr.db;
      };
      "germond.org" = {
        data = pkgs.lib.readFile ../data/dns/zones/germond.org.db;
      };
      "gistre.fr" = {
        data = dns.lib.toString "gistre.fr" (import ../data/dns/zones/gistre.fr.db.nix { inherit dns; });
      };
    };
  };
}
