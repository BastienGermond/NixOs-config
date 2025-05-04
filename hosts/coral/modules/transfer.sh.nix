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
      s3-endpoint = "https://s3-garage.germond.org";
      s3-region = "anemone";
      s3-path-style = true;
      bucket = "transfer.sh";

      max-upload-size = 31457280; # Restrict to 30GiB

      purge-days = 7;
    };
  };
}
