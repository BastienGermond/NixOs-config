{
  pkgs,
  lib,
  infra,
  ...
}: {
  networking.nat.internalInterfaces = builtins.attrNames infra.hosts.coral.wireguard;

  networking.firewall.allowedUDPPorts = [51821];

  networking.wireguard.interfaces = lib.mkMerge [
    {
      wgs0 = {
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.10.0/24 -o eth0 -j MASQUERADE
        '';

        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.10.0/24 -o eth0 -j MASQUERADE
        '';
      };
    }
  ];
}
