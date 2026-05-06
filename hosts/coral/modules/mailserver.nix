{config, ...}: {
  mailserver = {
    fqdn = "mx.germond.org";
    sendingFqdn = "germond.org";
    domains = ["germond.org"];

    localDnsResolver = false;

    lmtpSaveToDetailMailbox = false;

    x509 = {
      certificateFile = "${config.security.acme.certs."germond.org".directory}/fullchain.pem";
      privateKeyFile = "${config.security.acme.certs."germond.org".directory}/key.pem";
    };

    accounts = {
      "no-reply@germond.org" = {
        # name = "no-reply@germond.org";
        hashedPasswordFile = config.sops.secrets.noReplyMailPassword.path;
        sendOnly = true;
      };
      "abuse@germond.org" = {
        # name = "abuse@germond.org";
        hashedPasswordFile = config.sops.secrets.abuseMailPassword.path;
      };
      "test@germond.org" = {
        # name = "test@germond.org";
        hashedPasswordFile = config.sops.secrets.testMailPassword.path;
      };
    };

    stateVersion = 3;
  };
}
