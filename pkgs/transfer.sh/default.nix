{ config, pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "tansfer.sh";
  version = "1.5.0";

  src = pkgs.fetchFromGitHub {
    owner = "dutchcoders";
    repo = "transfer.sh";
    rev = "v${version}";
    sha256 = "sha256-6nq7yjhYsreMtwuQf4RLGxupSMDtRsha7LimuOSBYBk=";
  };

  ldflags = [
    "-X github.com/dutchcoders/transfer.sh/cmd.Version=${version}-nix -a -s -w -extldflags '-static'"
  ];

  tags = [ "netgo" ];

  CGO_ENABLED = false;

  vendorSha256 = "sha256-ngmmJga9vxNTp0UGyiKYfaPATipXny7DLjeEPhyW5m0=";
}
