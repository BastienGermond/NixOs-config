{ pkgs, config, ... } :

{
  services.bind = {
    enable = true;
    zones = [
      "synapze.fr" = {
        master = true;
        file = ../data/dns/zones/synapze.fr.db;
      };
      "germond.org" = {
        master = true;
        file = ../data/dns/zones/germond.org.db;
      };
      "gistre.fr" = {
        master = true;
        file = ../data/dns/zones/gistre.fr.db;
      }
    ];
  }
}
