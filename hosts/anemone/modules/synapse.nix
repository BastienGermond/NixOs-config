{
  config,
  infra,
  ...
}: {
  networking.firewall.allowedTCPPorts = [];

  services.matrix-synapse = {
    enable = true;
    dataDir = "/datastore/matrix-synapse/data";
    settings = {
      server_name = "germond.org";
      database.name = "psycopg2";

      enable_metrics = true;

      listeners = [
        {
          bind_addresses = ["10.100.10.2"];
          port = 8008;
          resources = [
            {
              compress = true;
              names = [
                "client"
              ];
            }
            {
              compress = false;
              names = [
                "federation"
              ];
            }
          ];
          tls = false;
          type = "http";
          x_forwarded = true;
        }
        {
          type = "metrics";
          bind_addresses = ["10.100.10.2"];
          port = infra.hosts.anemone.ports.matrix-synapse-monitoring;
          tls = false;
          resources = [
            {
              compress = true;
              names = ["metrics"];
            }
          ];
        }
      ];

      max_upload_size = "50M";

      registration_shared_secret_path = config.sops.secrets.SynapseRegistrationSharedSecret.path;
    };
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensurePermissions = {
          "DATABASE \"matrix-synapse\"" = "ALL PRIVILEGES";
        };
      }
    ];
    # If it's the first time, must run to fix issues with collate
    # psql# update pg_database set datctype='C',  datcollate='C' where datname='matrix-synapse';
    ensureDatabases = ["matrix-synapse"];
  };
}
