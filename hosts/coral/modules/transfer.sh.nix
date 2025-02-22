{
  config,
  pkgs,
  ...
}: {
  services.transfer_sh = {
    package = pkgs.transfer-sh;
    envFile = config.sops.secrets.transferShEnv.path;
    config = {
      listener = "127.0.0.1:9032";

      # Provider
      provider = "s3";
      s3-endpoint = "https://s3.germond.org";
      s3-region = "eu-west-3";
      s3-path-style = true;
      bucket = "transfer.sh";

      max-upload-size = 5000000; # Restrict to 5GB

      purge-days = 7;
    };
  };
}
