{
  config,
  pkgs,
  ...
}: {
  services.openvpn = {
    servers = {
      # pia = {
      #   config = "config ${config.sops.secrets.PIAOpenVPNConfig.path}";
      # };
    };
  };
}
