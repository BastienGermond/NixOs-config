{ pkgs, config, dns, ... }:

{
  services.nsd = {
    enable = false;
    verbosity = 3;
    interfaces = [ "0.0.0.0" ];
    # TSIG key used for wildcard certificate
    keys = {
      "rfc2136key.germond.org" = {
        algorithm = "hmac-sha512";
        keyFile = config.sops.secrets.nsdGermondOrgTsigSecret.path;
      };
    };
    enableGistreFr = true;
    zones = {
      "synapze.fr" = {
        data = dns.lib.toString "synapze.fr" (import ../data/dns/zones/synapze.fr.db.nix { inherit dns; });
      };
      "germond.org" = {
        data = dns.lib.toString "germond.org" (import ../data/dns/zones/germond.org.db.nix { inherit dns; });
      };
    };
  };
}


