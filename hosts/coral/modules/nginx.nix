{ config, lib, pkgs, ... }:

let
  certs_mail_addr = "bastien.germond+certs@epita.fr";

  gistre_fr_site = pkgs.stdenv.mkDerivation {
    name = "gistre-fr-site";

    src = pkgs.fetchFromGitHub {
      owner = "BastienGermond";
      repo = "gistre.fr";
      rev = "d8e9b70600ff9f9ced2696da7deacb6eba604a7d";
      sha256 = "sha256-bt0U5gSHwdLy4sUdbeSrLopCcGIqeEyEJyTGS3ETVuA=";
    };

    installPhase = ''
      mkdir $out
      cp -r site/* $out
    '';
  };
in
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "gistre.fr" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "${gistre_fr_site}";
        };
      };

      "sso.germond.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://10.100.10.2:9000/";
          proxyWebsockets = true;
        };
      };

      "cloud.germond.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://10.100.10.2/";
          proxyWebsockets = true;
        };
      };
    };
  };

  security.acme.acceptTerms = true;
  security.acme.certs = {
    "gistre.fr".email = certs_mail_addr;
    "sso.germond.org".email = certs_mail_addr;
    "cloud.germond.org".email = certs_mail_addr;
  };
}
