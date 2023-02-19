{ pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "gatus";
  version = "5.3.1";

  src = pkgs.fetchFromGitHub {
    owner = "TwiN";
    repo = "gatus";
    rev = "v${version}";
    sha256 = "sha256-64H1Y3a1RJbo+tX2SBePwHWCEvQXnwyqgowcnOvKreQ=";
  };

  vendorSha256 = "sha256-ziKdlOFOddh/CBqYsr74iMpIelE8Idv+fA2aSe5h+X8=";

  doCheck = false;
}

