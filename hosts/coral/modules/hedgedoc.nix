{config, ...}: {
  services.hedgedoc = {
    environmentFile = config.sops.secrets.hedgedocEnv.path;
    settings = {
      domain = "hackmd.germond.org";
      dbURL = "postgres://hedgedoc@127.0.0.1:5432/hedgedoc?sslmode=disable";
      s3bucket = "minio";
      allowAnonymous = false;
      allowAnonymousEdits = true;
      email = false;
      allowEmailRegister = false;
      protocolUseSSL = true;
    };
  };

  services.postgresql.ensureDatabases = ["hedgedoc"];
  services.postgresql.ensureUsers = [
    {
      name = "hedgedoc";
      ensureDBOwnership = true;
    }
  ];

  services.postgresqlCipheredBackup.databases = ["hedgedoc"];
}
