{pkgs, ...}: let
  gistre_fr_site = pkgs.stdenv.mkDerivation {
    name = "gistre-fr-site";

    src = pkgs.fetchFromGitHub {
      owner = "BastienGermond";
      repo = "gistre.fr";
      rev = "efa716c7ff48c8d52cd19f9b55aa2fa92994b3bd";
      sha256 = "sha256-2WaFELIF7gXrelhPbhCnZ4ubO4E7KB7/HAy1piIKULY=";
    };

    installPhase = ''
      mkdir $out
      cp -r site/* $out
    '';
  };
in {
  forceSSL = true;
  enableACME = true;
  extraConfig = ''
    access_log /var/log/nginx/access-gistre.fr.log;
  '';
  locations."/" = {
    root = "${gistre_fr_site}";
  };
}
