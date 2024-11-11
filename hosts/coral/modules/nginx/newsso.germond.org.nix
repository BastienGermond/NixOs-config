{
  coral,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "newsso.germond.org" {
  extraConfig = ''
    proxy_busy_buffers_size       512k;
    proxy_buffers             4   512k;
    proxy_buffer_size             256k;
  '';

  locations."/" = {
    proxyPass = "http://127.0.0.1:${builtins.toString coral.ports.keycloak}/";
    proxyWebsockets = true;
    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Host $server_name;
    '';
  };
}
