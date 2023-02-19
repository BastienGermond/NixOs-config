# vim:shiftwidth=2
{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = { url = "github:nix-community/home-manager/release-22.11"; inputs.nixpkgs.follows = "nixpkgs"; };
    flake-utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nvim-flake = { url = "github:neovim/neovim/v0.8.3?dir=contrib"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dns = { url = "github:kirelagin/dns.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    deploy-rs = { url = "github:serokell/deploy-rs"; inputs.nixpkgs.follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    gistre-fr-db = { url = "github:BastienGermond/gistre.fr.db"; inputs.dns.follows = "dns"; };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , flake-utils
    , home-manager
    , nixos-hardware
    , nvim-flake
    , dns
    , deploy-rs
    , sops-nix
    , gistre-fr-db
    , ...
    } @ inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      nodes = import ./nodes.nix {
        inherit deploy-rs;
        nixosConfigurations = self.nixosConfigurations;
      };
      infra = import ./hosts/infra.nix;
    in
    flake-utils.lib.mkFlake {
      inherit self inputs;

      supportedSystems = supportedSystems;

      hostDefaults = {
        modules = [
          sops-nix.nixosModules.sops
          gistre-fr-db.nixosModules.default
          home-manager.nixosModule
          ./modules
        ];
        extraArgs = { inherit dns infra; };
      };

      channelsConfig = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "qtwebkit-5.212.0-alpha4"
        ];
      };

      channels.nixpkgs.input = nixpkgs-unstable;

      channels.nixpkgs.overlaysBuilder = channels: [
        (final: prev: {
          # Unstable branch
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};

          # Custom packages
          spotibar = final.callPackage ./pkgs/spotibar/default.nix { };
          gatus = final.callPackage ./pkgs/gatus/default.nix { };
          transfer_sh = final.callPackage ./pkgs/transfer.sh/default.nix { };
          immich-server = final.callPackage ./pkgs/immich/server/default.nix { };

          kicad = nixpkgs-unstable.legacyPackages.${prev.system}.kicad;

          neovim = nvim-flake.packages.${prev.system}.neovim;
          # neovim = nixpkgs-unstable.legacyPackages.${prev.system}.neovim;

          # Mitigation for https://mta.openssl.org/pipermail/openssl-announce/2022-October/000238.html
          nginxStable = prev.nginxStable.override { openssl = prev.openssl_1_1; };
        })
      ];

      hosts = {
        "synapze-pc".modules = [
          nixos-hardware.nixosModules.dell-xps-13-9360
          ./hosts/synapze-pc
          (import ./home { })
          ./modules
          ./modules/xorg.nix
        ];

        "anemone".modules = [
          ./hosts/anemone
          (import ./home { isMinimal = true; })
          ./modules
        ];

        "coral".modules = [
          ./hosts/coral
          (import ./home { isMinimal = true; })
          ./modules
        ];
      };

      formatter.x86_64-linux = self.pkgs.x86_64-linux.nixpkgs.nixpkgs-fmt;

      deploy.nodes = nodes.nodes;

      outputsBuilder = channels: {
        devShells.default = channels.nixpkgs.mkShell {
          buildInputs = with channels.nixpkgs; [
            age-plugin-yubikey
            deploy-rs.packages.${system}.deploy-rs
          ];
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
