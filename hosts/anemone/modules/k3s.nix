{
  config,
  pkgs,
  ...
}: {
  services.k3s = {
    enable = false;
    role = "server";
    extraFlags = "--disable traefik --disable metrics-server --disable servicelb";
  };
}
