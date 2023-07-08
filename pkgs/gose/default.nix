{
  pkgs,
  version ? "0.6.0",
  ...
}: let
  gose-src = pkgs.fetchFromGitHub {
    owner = "BastienGermond";
    repo = "gose";
    rev = "588bc780405b5f03ae4b41d7d0cec397ffd4a65b";
    sha256 = "sha256-dlogUja3onMK1i645qStHLoS2dXg5Z8SBSiI10lEQwk=";
  };

  gose-static = pkgs.buildNpmPackage {
    pname = "gose-static";
    version = version;

    src = gose-src;

    sourceRoot = "source/frontend";

    npmDepsHash = "sha256-n2wjmg8E72/R7p44/nceiOyUXgRkgL/HkNn5IAPSXjA=";
  };

  gose-src-embed = pkgs.stdenv.mkDerivation {
    pname = "gose-src-embed";
    version = gose-src.rev;

    src = gose-src;

    installPhase = ''
      mkdir $out
      cp -r * $out
      cp -r ${gose-static}/lib/node_modules/gose/dist $out/frontend
    '';
  };

  gose-bin = pkgs.buildGoModule rec {
    pname = "gose-bin";

    inherit version;

    src = gose-src-embed;

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
      "-X main.commit=${gose-src.rev}"
      "-X main.builtBy=nix"
    ];

    tags = ["embed"];

    vendorSha256 = "sha256-ch9CVV6Dq5y8krTViPquc8eU6JQxXGB7o/G//1GB5mY=";

    doCheck = false;
  };
in
  pkgs.stdenv.mkDerivation {
    pname = "gose";
    inherit version;

    src = gose-bin;

    installPhase = ''
      mkdir -p $out/bin
      [ -e $out/bin ] && cp -rp bin/cmd $out/bin/gose
    '';
  }
