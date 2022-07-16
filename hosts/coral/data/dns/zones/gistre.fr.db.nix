{ dns }:

with dns.lib.combinators;

{
  SOA = {
    nameServer = "ns1.synapze.fr.";
    adminEmail = "root@synapze.fr";
    serial = 2021081401;
  };

  NS = [
    "ns1.synapze.fr."
  ];

  A = [ "135.181.36.15" ];

  subdomains = {
    doc.CNAME = [ "ing.pages.epita.fr." ];

    esteban.CNAME = [ "skallwar.fr." ];
    skallwar.CNAME = [ "skallwar.fr." ];
  };
}
