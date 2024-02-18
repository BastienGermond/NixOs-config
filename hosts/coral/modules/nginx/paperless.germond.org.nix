{
  anemone,
  withDefaultConfiguration,
  ...
}:
withDefaultConfiguration "paperless.germond.org" {
  extraConfig = ''
    proxy_buffers 8 16k;
    proxy_buffer_size 32k;
  '';

  locations."/" = {
    priority = 50;
    proxyWebsockets = true;
    extraConfig = ''
      proxy_pass http://${anemone.ips.vpn.A}:${builtins.toString anemone.ports.paperless};

      proxy_redirect off;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Host $server_name;

      ##############################
      # authentik-specific config
      ##############################
      auth_request     /outpost.goauthentik.io/auth/nginx;
      error_page       401 = @goauthentik_proxy_signin;
      auth_request_set $auth_cookie $upstream_http_set_cookie;
      add_header       Set-Cookie $auth_cookie;

      # translate headers from the outposts back to the actual upstream
      auth_request_set $authentik_username $upstream_http_x_authentik_username;
      auth_request_set $authentik_groups $upstream_http_x_authentik_groups;
      auth_request_set $authentik_email $upstream_http_x_authentik_email;
      auth_request_set $authentik_name $upstream_http_x_authentik_name;
      auth_request_set $authentik_uid $upstream_http_x_authentik_uid;

      proxy_set_header X-authentik-username $authentik_username;
      proxy_set_header X-authentik-groups $authentik_groups;
      proxy_set_header X-authentik-email $authentik_email;
      proxy_set_header X-authentik-name $authentik_name;
      proxy_set_header X-authentik-uid $authentik_uid;
    '';
  };
}
