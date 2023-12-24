{pkgs, ...}:
pkgs.buildGoModule rec {
  pname = "fail2ban-prometheus-exporter";
  version = "0.7.2";

  src = pkgs.fetchFromGitLab {
    owner = "hectorjsmith";
    repo = "fail2ban-prometheus-exporter";
    rev = "${version}";
    sha256 = "sha256-W5Y0lTGxrSWCBDMGOjt/m8Qa8xjIy2q+lZMwltIHEeg=";
  };

  patches = [
    ./fix-go-mod-version.patch
  ];

  sourceRoot = "source/src";

  vendorHash = "sha256-2h7x8dGEGHIrKeubQnsjKs7+P+BN1Vrse6CbnpC8bxs=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
    "-X main.commit=${src.rev}"
    "-X main.builtBy=nix"
  ];
}
