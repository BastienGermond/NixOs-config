{ pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "gatus";
  version = "5.3.2";

  src = pkgs.fetchFromGitHub {
    owner = "TwiN";
    repo = "gatus";
    rev = "v${version}";
    sha256 = "sha256-0y6KHvYexZiBJX1Z+zQtvPzsZbLc0SAk1xirZFBGJSk=";
  };

  vendorSha256 = "sha256-ITkKaNlY3Q7A+7sMcSoyyVqiXgnVotfM/ZAn6QcUGII=";

  doCheck = false;
}

