{
  config,
  pkgs,
  ...
}: {
  security.pam.sshAgentAuth.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };
}
