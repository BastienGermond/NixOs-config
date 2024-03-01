{
  config,
  pkgs,
  ...
}: {
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      trusted-users = ["synapze"];
      substituters = [
        "https://helix.cachix.org"
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
