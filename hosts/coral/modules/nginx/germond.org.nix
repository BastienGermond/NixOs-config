{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "germond.org" (
  let
    clientConfig = {
      "m.homeserver".base_url = "https://germond.org";
      "m.identity_server" = {};
    };
    serverConfig."germond.org" = "https://germond.org:443";
    mkWellKnown = data:
    # nginx
    ''
      add_header Content-Type application/json;
      add_header Access-Control-Allow-Origin *;
      return 200 '${builtins.toJSON data}';
    '';
  in {
    extraConfig =
      # nginx
      ''
        # For the federation port
        listen 8448 ssl http2 default_server;
        listen [::]:8448 ssl http2 default_server;

        client_max_body_size 50M;
      '';

    locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
    locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
    locations."/_matrix".proxyPass = "http://${anemone.ips.vpn.A}:8008";
    locations."/_synapse/client".proxyPass = "http://${anemone.ips.vpn.A}:8008";
    locations."= /matrix/health".proxyPass = "http://${anemone.ips.vpn.A}:8008/health";
    locations."/".return = "444";
  }
)
