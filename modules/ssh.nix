{
  config,
  pkgs,
  ...
}: {
  security.pam.enableSSHAgentAuth = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };
}
