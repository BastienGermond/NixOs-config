{ pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "gatus";
  version = "4.3.2";

  src = pkgs.fetchFromGitHub {
    owner = "TwiN";
    repo = "gatus";
    rev = "v${version}";
    sha256 = "sha256-wphGGKSlx56EN44yTQoGdov+hBFeYiLxV2zKyOAM8ss=";
  };

  vendorSha256 = null;

  doCheck = false;
}

