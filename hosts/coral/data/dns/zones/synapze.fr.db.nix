{dns}:
with dns.lib.combinators; {
  SOA = {
    nameServer = "ns1.synapze.fr.";
    adminEmail = "root@synapze.fr";
    serial = 2021051301;
  };

  NS = [
    "ns1.synapze.fr."
  ];

  A = ["135.181.36.15"];

  subdomains = {
    ns1.A = ["135.181.36.15"];
    ns2.A = ["135.181.36.15"];
  };
}
