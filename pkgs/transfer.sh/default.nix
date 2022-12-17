{ config, pkgs, ... }:

pkgs.buildGoModule rec {
  pname = "tansfer.sh";
  version = "1.4.0";

  src = pkgs.fetchFromGitHub {
    owner = "dutchcoders";
    repo = "transfer.sh";
    rev = "v${version}";
    sha256 = "sha256-8XMeLIhVWqXBeQToVSyLxEBgLVhCZ+kAf96Cti5e04U=";
  };

  ldflags = [
    "-X github.com/dutchcoders/transfer.sh/cmd.Version=${version}-nix -a -s -w -extldflags '-static'"
  ];

  tags = [ "netgo" ];

  CGO_ENABLED = false;

  vendorSha256 = "sha256-d7EMXCtDGp9k6acVg/FiLqoO1AsRzoCMkBb0zen9IGc=";
}
