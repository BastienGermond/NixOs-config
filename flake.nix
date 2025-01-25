# vim:shiftwidth=2
{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    kicad-nixpkgs.url = "github:NixOS/nixpkgs/d045216e9c0595cc44be18e7cc79372062e0448f"; # 8.0.5
    # immich-nixpkgs.url = "github:NixOS/nixpkgs/ceaedafdcb9cb3ffcaa34b3db2705fae0f28e840"; # 1.123.0
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-utils.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.5.1";
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
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixd.url = "github:nix-community/nixd";
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
    # immich-nixpkgs,
    flake-utils,
    home-manager,
    nixos-hardware,
    dns,
    deploy-rs,
    sops-nix,
    gistre-fr-db,
    nixos-mailserver,
    nixd,
    nix-matlab,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux"];
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

      channels.nixpkgs.config = {
        disabledModules = [
        ];
      };

      channels.nixpkgs.overlaysBuilder = channels: [
        (final: prev: {
          # Unstable branch
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};

          # Custom packages
          spotibar = final.callPackage ./pkgs/spotibar/default.nix {};
          # transfer_sh = final.callPackage ./pkgs/transfer.sh/default.nix {};
          gose = final.callPackage ./pkgs/gose/default.nix {};
          fail2ban-prometheus-exporter = final.callPackage ./pkgs/fail2ban-prometheus-exporter {};

          nixd = nixd.packages.${prev.system}.nixd;

          kicad = kicad-nixpkgs.legacyPackages.${prev.system}.kicad;

          nginxStable = prev.nginxStable.override {openssl = prev.pkgs.libressl;};
          # immich-pinned = immich-nixpkgs.legacyPackages.${prev.system}.immich;
          immich = nixpkgs.legacyPackages.${prev.system}.immich;
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

        # "rpi-1" = {
        #   system = "aarch64-linux";
        #   modules = [
        #     nixos-hardware.nixosModules.raspberry-pi-4
        #     ./hosts/rpi-1
        #     ./home
        #   ];
        # };
      };

      formatter.x86_64-linux = self.pkgs.x86_64-linux.nixpkgs.alejandra;

      deploy.nodes = nodes.nodes;

      outputsBuilder = channels: {
        devShells.default = channels.nixpkgs.mkShell {
          buildInputs =
            (builtins.attrValues {
              inherit (channels.nixpkgs) age-plugin-yubikey sops just;
            })
            ++ [
              deploy-rs.packages.${channels.nixpkgs.system}.deploy-rs
            ];
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
