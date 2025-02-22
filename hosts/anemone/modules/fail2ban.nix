{
  config,
  pkgs,
  ...
}: {
  # Allow port for fail2ban prometheus exporter
  networking.firewall.allowedTCPPorts = [9191];

  systemd.services.fail2ban-prometheus-exporter = {
    description = "Fail2ban prometheus exporter";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.fail2ban-prometheus-exporter}/bin/fail2ban-prometheus-exporter";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  services.fail2ban = {
    bantime = "-1"; # permanent ban

    ignoreIP = [
      "10.100.10.0/24"
    ];

    extraPackages = [pkgs.ipset];
    banaction = "iptables-allports";
    banaction-allports = "iptables-allports";

    jails = {
      sshd.settings.bantime = "-1";
      gitea-ssh = ''
        enabled = true
        filter = gitea-ssh
        logpath = /var/lib/gitea/log/gitea.log
        maxretry = 1
        bantime = -1
        journalmatch = _SYSTEMD_UNIT=gitea.service
        action = %(banaction)s[protocol="all", blocktype="DROP"]
      '';
      # action = iptables-allports
    };
  };

  environment.etc = {
    "fail2ban/filter.d/gitea-ssh.conf".text = ''
      [INCLUDES]
      before = common.conf

      [Definition]
      failregex =  .*(Failed authentication attempt|invalid credentials|Attempted access of unknown user).* from <HOST>
      ignoreregex =
    '';
  };
}
