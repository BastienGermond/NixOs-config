{...}: {
  imports = [
    # ./nsd.nix
    ./attic.nix
    ./bind.nix
    ./fail2ban.nix
    ./gatus.nix
    ./grafana.nix
    ./hedgedoc.nix
    ./homepage-dashboard.nix
    ./keycloak.nix
    ./mailserver.nix
    ./monitoring.nix
    ./nginx.nix
    ./packages.nix
    ./scrutiny.nix
    ./sops.nix
    ./ssh.nix
    ./transfer.sh.nix
    ./vouch.nix
    ./wireguard.nix
  ];
}
