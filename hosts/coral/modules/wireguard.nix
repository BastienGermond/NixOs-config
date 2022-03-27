{ config, pkgs, ... }:

{
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wgs0" ];

  networking.wireguard.interfaces = {
    wgs0 = {
      ips = [ "10.100.10.1/24" ];
      listenPort = 51821;
      privateKeyFile = "/root/.wg/wgs0.pkey";

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.10.0/24 -o eth0 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.10.0/24 -o eth0 -j MASQUERADE
      '';

      peers = [
        {
          publicKey = "rQukuG5PzfSBX4Q28ubHVWGIN+e75Mm8NzPaK8y601A=";
          allowedIPs = [ "10.100.10.18/32" ];
        }
        {
          publicKey = "ptVPzlnSRGpOVrlD/cYhvG/AKEAWe32UaDPAo0ivnG4=";
          allowedIPs = [ "10.100.10.2/32" ];
        }
        {
          publicKey = "hHWuxL+GuQ78uZNcUqTqyTdsCNDXXlsMlxf6IFm5ZUM=";
          allowedIPs = [ "10.100.10.3/32" ];
        }
      ];
    };
  };
}
