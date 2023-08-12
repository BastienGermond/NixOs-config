{
  config,
  pkgs,
  ...
}: {
  imports = [
    # ./nsd.nix
    ./bind.nix
    ./fail2ban.nix
    ./gatus.nix
    ./grafana.nix
    ./hedgedoc.nix
    ./keycloak.nix
    ./mailserver.nix
    ./monitoring.nix
    ./nginx.nix
    ./packages.nix
    ./sops.nix
    ./ssh.nix
    ./transfer.sh.nix
    ./wireguard.nix
  ];
}
