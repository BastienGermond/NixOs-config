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
    cloud.CNAME = [ "germond.org." ];
    sso.CNAME = [ "germond.org." ];
    grafana.CNAME = [ "germond.org." ];
    status.CNAME = [ "germond.org." ];
    minio.CNAME = [ "germond.org." ];
    s3.CNAME = [ "germond.org." ];
    t.CNAME = [ "germond.org." ];
    paperless.CNAME = [ "germond.org." ];
    hackmd.CNAME = [ "germond.org." ];
    yamaha = {
      A = [ "193.48.57.161" ];
      AAAA = [ "2001:660:4401:60a0:216:3eff:fe63:515a" ];
      MX = [{
        preference = 50;
        exchange = "yamaha.germond.org.";
      }];
    };
  };
}
