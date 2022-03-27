{ config, lib, pkgs, ... }:

let
  gistre_fr_site = pkgs.stdenv.mkDerivation {
    name = "gistre-fr-site";

    src = pkgs.fetchFromGitHub {
      owner = "BastienGermond";
      repo = "gistre.fr";
      rev = "d8e9b70600ff9f9ced2696da7deacb6eba604a7d";
      sha256 = lib.fakeSha256;
    };

    installPhase = ''
      cp -v -r site/* $out
    '';
  };
in
{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "gistre.fr" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "${gistre_fr_site}";
        };
      };
    };
  };

  security.acme.acceptTerms = true;
  security.acme.certs = {
    "gistre.fr".email = "bastien.germond+certs@epita.fr";
  };
}
