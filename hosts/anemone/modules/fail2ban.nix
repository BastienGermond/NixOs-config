{
  config,
  pkgs,
  ...
}: {
  # Allow port for fail2ban prometheus exporter
  networking.firewall.allowedTCPPorts = [ 9191 ];

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

    ignoreIP = [
      "10.100.10.0/24"
    ];

    extraPackages = [pkgs.ipset];
    banaction = "iptables-ipset-proto6-allports";

    jails = {
      sshd.settings.bantime = "-1";
      gitea-ssh = ''
        enabled = true
        filter = gitea-ssh
        logpath = /var/lib/gitea/log/gitea.log
        maxretry = 1
        action = iptables-allports
        bantime = -1
      '';
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
