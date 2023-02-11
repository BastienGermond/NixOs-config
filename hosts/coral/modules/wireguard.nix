{ config, pkgs, lib, infra, ... }:

{
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = builtins.attrNames infra.hosts.coral.wireguard;

  networking.wireguard.interfaces = lib.mkMerge [
    infra.hosts.coral.wireguard
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
