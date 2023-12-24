{pkgs, ...}:
pkgs.buildGoModule rec {
  pname = "gatus";
  version = "5.5.1";

  src = pkgs.fetchFromGitHub {
    owner = "TwiN";
    repo = "gatus";
    rev = "v${version}";
    sha256 = "sha256-fKXLt0K6DduzXhvPs1Ma3ZOhMY515+IgKr9aTNZjbUw=";
  };

  vendorHash = "sha256-s+fZ/bVwVCEFu/lIIexGY+rPexsnTKqYcYqsRisfm90=";

  doCheck = false;
}
