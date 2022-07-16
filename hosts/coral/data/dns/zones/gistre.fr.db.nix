{ dns }:

with dns.lib.combinators;

# In case you change something don't forget to also update the serial field

{
  SOA = {
    nameServer = "ns1.synapze.fr.";
    adminEmail = "root@synapze.fr";
    serial = 2022071601; # <year><month><day><patch>
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
