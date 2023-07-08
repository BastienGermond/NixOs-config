{
  config,
  pkgs,
  ...
}: {
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
    enable = true;
    bantime = "-1"; # permanent ban

    extraPackages = [pkgs.ipset];
    banaction = "iptables-ipset-proto6-allports";

    jails = {
      sshd-invaliduser = ''
        enabled = true
        filter = sshd-invaliduser
        maxretry = 1
        port = ssh
        logpath = %(sshd_log)s
        backend = %(sshd_backend)s
      '';
    };
  };

  environment.etc = {
    "fail2ban/filter.d/sshd-invaliduser.conf".text = ''
      [INCLUDES]
      before = common.conf

      [Definition]
      _daemon = sshd

      failregex = ^%(__prefix_line)s[iI](?:llegal|nvalid) user .*? from <HOST>(?: port \d+)?\s*$
      ignoreregex =

      [Init]
      journalmatch = _SYSTEMD_UNIT=sshd.service + _COMM=sshd
    '';
  };
}
