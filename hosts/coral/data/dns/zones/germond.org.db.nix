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
  AAAA = [ "2a01:4f9:c010:b3c0::" ];

  MX = [{
    preference = 50;
    exchange = "mx.germond.org.";
  }];

  TXT = [
    "v=spf1 a:mx.germond.org ip4:135.181.36.15 ~all"
  ];

  DKIM = [{
    selector = "mail";
    k = "rsa";
    p = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDTciDADhA2e+uFBv6HVPGpIhVXLng2MkdB7lTw0m6HnfN25GQKf49unO4Oz4Yvd0DrwwlOE3A2tWtx1qw+hMr9xBO2eOB0Xc9WAVc7p0A2FTmMBaSBZ5n7bg71KEw8aJEnQmBLcrz+RgWYAwdcjY0BNwgRsi/WOH2ceXO1h0UtiwIDAQAB";
    s = ["email"];
  }];

  subdomains = {
    mx.CNAME = [ "germond.org" ];
    _dmarc.TXT = [ "v=DMARC1; p=none" ];
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
