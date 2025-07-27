{...}: {
  services.openssh.ports = [2222];

  networking.firewall.allowedTCPPorts = [2222];
}
