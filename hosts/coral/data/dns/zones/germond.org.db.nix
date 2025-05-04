{dns}:
with dns.lib.combinators; {
  SOA = {
    nameServer = "ns1.germond.org.";
    adminEmail = "abuse@germond.org";
    serial = 25050402; # YYMMDDPP
  };

  NS = [
    "ns1.germond.org."
    "ns2.germond.org."
  ];

  A = ["135.181.36.15"];
  AAAA = ["2a01:4f9:c010:b3c0::1"];

  MX = [
    {
      preference = 50;
      exchange = "mx.germond.org.";
    }
  ];

  TXT = [
    "v=spf1 a:mx.germond.org ip4:135.181.36.15 ip6:2a01:4f9:c010:b3c0::1 ~all"
  ];

  DKIM = [
    {
      selector = "mail";
      k = "rsa";
      p = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDTciDADhA2e+uFBv6HVPGpIhVXLng2MkdB7lTw0m6HnfN25GQKf49unO4Oz4Yvd0DrwwlOE3A2tWtx1qw+hMr9xBO2eOB0Xc9WAVc7p0A2FTmMBaSBZ5n7bg71KEw8aJEnQmBLcrz+RgWYAwdcjY0BNwgRsi/WOH2ceXO1h0UtiwIDAQAB";
      s = ["email"];
    }
  ];

  subdomains = {
    mx = {
      A = ["135.181.36.15"];
      AAAA = ["2a01:4f9:c010:b3c0::1"];
    };

    ns1 = {
      A = ["135.181.36.15"];
      AAAA = ["2a01:4f9:c010:b3c0::1"];
    };
    ns2 = {
      A = ["135.181.36.15"];
      AAAA = ["2a01:4f9:c010:b3c0::1"];
    };

    _dmarc.TXT = ["v=DMARC1; p=quarantine; rua=mailto:abuse@germond.org;"];
    alert.CNAME = ["germond.org."];
    cache.CNAME = ["germond.org."];
    cloud.CNAME = ["germond.org."];
    docs.CNAME = ["germond.org."];
    git.CNAME = ["germond.org."];
    grafana.CNAME = ["germond.org."];
    hackmd.CNAME = ["germond.org."];
    home.CNAME = ["germond.org."];
    immich.CNAME = ["germond.org."];
    komga.CNAME = ["germond.org."];
    minio.CNAME = ["germond.org."];
    newsso.CNAME = ["germond.org."];
    paperless.CNAME = ["germond.org."];
    prometheus.CNAME = ["germond.org."];
    s3.CNAME = ["germond.org."];
    scrutiny.CNAME = ["germond.org."];
    sso.CNAME = ["germond.org."];
    status.CNAME = ["germond.org."];
    t.CNAME = ["germond.org."];
    videos.CNAME = ["germond.org."];
    vouch.CNAME = ["germond.org."];
    s3-garage.CNAME = ["germond.org."];
    web-garage.CNAME = ["germond.org."];
  };
}
