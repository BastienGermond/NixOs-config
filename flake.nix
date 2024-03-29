# vim:shiftwidth=2
{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    kicad-nixpkgs.url = "github:NixOS/nixpkgs/9957cd48326fe8dbd52fdc50dd2502307f188b0d"; # 7.0.7
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
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
    };
    helix = {url = "github:helix-editor/helix";};
    nixd = {url = "github:nix-community/nixd";};
    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    kicad-nixpkgs,
    flake-utils,
    home-manager,
    nixos-hardware,
    dns,
    deploy-rs,
    sops-nix,
    gistre-fr-db,
    nixos-mailserver,
    helix,
    nixd,
    nix-matlab,
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
          transfer_sh = final.callPackage ./pkgs/transfer.sh/default.nix {};
          gose = final.callPackage ./pkgs/gose/default.nix {};
          fail2ban-prometheus-exporter = final.callPackage ./pkgs/fail2ban-prometheus-exporter {};

          helix = helix.packages.${prev.system}.helix;
          nixd = nixd.packages.${prev.system}.nixd;

          kicad = kicad-nixpkgs.legacyPackages.${prev.system}.kicad;

          # neovim = nvim-flake.packages.${prev.system}.neovim;
          # neovim = nixpkgs-unstable.legacyPackages.${prev.system}.neovim;

          nextcloud27 = nixpkgs.legacyPackages.${prev.system}.nextcloud27;

          nginxStable = prev.nginxStable.override {openssl = prev.pkgs.libressl;};
        })

        (nix-matlab.overlay)
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
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-cpu-amd-pstate
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
