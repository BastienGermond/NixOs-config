{withDefaultConfiguration, ...}:
withDefaultConfiguration "prometheus.germond.org" {
  locations."/validate" = {
    priority = 0;
    recommendedProxySettings = true;
    proxyPass = "http://127.0.0.1:9090/validate";

    extraConfig =
      # nginx
      ''
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";

        auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;
        auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
        auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
        auth_request_set $auth_resp_failcount $upstream_http_x_vouch_failcount;
        auth_request_set $auth_resp_x_vouch_idp_claims_groups $upstream_http_x_vouch_idp_claims_groups;
      '';
  };

  locations."@error401" = {
    priority = 10;
    return = "302 https://vouch.germond.org/login?url=$scheme://$host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err";
  };

  locations."/" = {
    recommendedProxySettings = true;
    proxyPass = "http://10.100.10.1:9001";
    extraConfig =
      # nginx
      ''
        proxy_set_header X-Vouch-User $auth_resp_x_vouch_user;
      '';
  };

  extraConfig =
    # nginx
    ''
      auth_request /validate;
      error_page 401 = @error401;
    '';
}
