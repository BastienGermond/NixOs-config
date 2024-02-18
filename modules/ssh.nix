{
  config,
  pkgs,
  lib,
  ...
}: {
  security.pam.sshAgentAuth = {
    enable = true;
    authorizedKeysFiles = [
      "/etc/ssh/authorized_keys.d/%u"
      # "%h/.ssh/authorized_keys" INSECURE
    ];
  };

  services.openssh = {
    enable = true;
    authorizedKeysFiles = lib.mkForce ["/etc/ssh/authorized_keys.d/%u"];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };

  users.users.synapze.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh2B4ZYF7UfJ//s1kK+uaSDYKfvcO94JMpk3VHLJY3h synapze@synapze-pc"
  ];
}
