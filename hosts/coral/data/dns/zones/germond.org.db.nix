{ dns }:

with dns.lib.combinators;

{
  SOA = {
    nameServer = "ns1.synapze.fr.";
    adminEmail = "root@synapze.fr";
    serial = 2022081101;
  };

  NS = [
    "ns1.synapze.fr."
  ];

  A = [ "135.181.36.15" ];

  subdomains = {
    intra.CNAME = [ "germond.org." ];
    cloud.CNAME = [ "germond.org." ];
    onlyoffice.CNAME = [ "germond.org." ];
    sso.CNAME = [ "germond.org." ];
    grafana.CNAME = [ "germond.org." ];
  };
}
