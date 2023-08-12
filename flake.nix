# vim:shiftwidth=2
{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nvim-flake = {
      url = "github:neovim/neovim/v0.8.3?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dns = {
      url = "github:kirelagin/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gistre-fr-db = {
      url = "github:BastienGermond/gistre.fr.db";
      inputs.dns.follows = "dns";
    };
    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix = {url = "github:helix-editor/helix";};
    nixd = {url = "github:nix-community/nixd";};
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    home-manager,
    nixos-hardware,
    nvim-flake,
    dns,
    deploy-rs,
    sops-nix,
    gistre-fr-db,
    nixos-mailserver,
    helix,
    nixd,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux"];
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
          nixos-mailserver.nixosModules.mailserver
          ./modules
        ];
        extraArgs = {inherit dns infra;};
      };

      channelsConfig = {
        allowUnfree = true;
        permittedInsecurePackages = [
          # "qtwebkit-5.212.0-alpha4"
        ];
      };

      channels.nixpkgs.input = nixpkgs-unstable;

      channels.nixpkgs.overlaysBuilder = channels: [
        (final: prev: {
          # Unstable branch
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};

          # Custom packages
          spotibar = final.callPackage ./pkgs/spotibar/default.nix {};
          gatus = final.callPackage ./pkgs/gatus/default.nix {};
          transfer_sh = final.callPackage ./pkgs/transfer.sh/default.nix {};
          gose = final.callPackage ./pkgs/gose/default.nix {};
          fail2ban-prometheus-exporter = final.callPackage ./pkgs/fail2ban-prometheus-exporter {};

          helix = helix.packages.${prev.system}.helix;
          nixd = nixd.packages.${prev.system}.nixd;

          kicad = nixpkgs-unstable.legacyPackages.${prev.system}.kicad;

          neovim = nvim-flake.packages.${prev.system}.neovim;
          # neovim = nixpkgs-unstable.legacyPackages.${prev.system}.neovim;

          nextcloud27 = nixpkgs.legacyPackages.${prev.system}.nextcloud27;

          nginxStable = prev.nginxStable.override {openssl = prev.pkgs.libressl;};
        })
      ];

      hosts = {
        "synapze-pc".modules = [
          nixos-hardware.nixosModules.dell-xps-13-9360
          ./hosts/synapze-pc
          ./home
          ./modules
          ./modules/xorg.nix
        ];

        "anemone".modules = [
          ./hosts/anemone
          ./home
          ./modules
        ];

        "coral".modules = [
          ./hosts/coral
          ./home
          ./modules
        ];
      };

      formatter.x86_64-linux = self.pkgs.x86_64-linux.nixpkgs.alejandra;

      deploy.nodes = nodes.nodes;

      outputsBuilder = channels: {
        devShells.default = channels.nixpkgs.mkShell {
          buildInputs = with channels.nixpkgs; [
            age-plugin-yubikey
            deploy-rs.packages.${system}.deploy-rs
            sops
          ];
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
