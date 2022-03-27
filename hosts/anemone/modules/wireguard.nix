{ config, pkgs, ... }:

{
  networking.nat.internalInterfaces = [ "wg0" ];

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.10.2/32" ];
      listenPort = 51821;
      privateKeyFile = "/root/.wg/wg0.pkey";

      peers = [
        {
          publicKey = "IOXJd4A9NO9JMcRcQRl5QYL8WW0s13+PMnyZVbbr728=";
          allowedIPs = [ "10.100.10.0/24" ];
          endpoint = "135.181.36.15:51821";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
