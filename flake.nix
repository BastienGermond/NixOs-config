{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    kicad-nixpkgs.url = "github:NixOS/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb1"; # 9.0.2
    # immich-nixpkgs.url = "github:NixOS/nixpkgs/ceaedafdcb9cb3ffcaa34b3db2705fae0f28e840"; # 1.123.0
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    komf = {
      url = "github:christian-blades-cb/komf.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
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
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nixd.url = "github:nix-community/nixd";
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
    komf,
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
          komf.nixosModules.default
          sops-nix.nixosModules.sops
          gistre-fr-db.nixosModules.default
          home-manager.nixosModules.default
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
          gose = final.callPackage ./pkgs/gose/default.nix {};
          fail2ban-prometheus-exporter = final.callPackage ./pkgs/fail2ban-prometheus-exporter {};
          chitubox-free-bin = final.callPackage ./pkgs/chitubox/default.nix {};
          freecad-assembly3 = final.callPackage ./pkgs/freecad-assembly3/default.nix {};

          nixd = nixd.packages.${prev.system}.nixd;

          kicad = kicad-nixpkgs.legacyPackages.${prev.system}.kicad;

          nginxStable = prev.nginxStable.override {openssl = prev.pkgs.libressl;};
          # immich-pinned = immich-nixpkgs.legacyPackages.${prev.system}.immich;
          immich = nixpkgs.legacyPackages.${prev.system}.immich;
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

        "nautilus".modules = [
          nixos-hardware.nixosModules.framework-amd-ai-300-series
          ./hosts/nautilus
          ./home
          ./modules
          ./modules/xorg.nix
        ];

        "capucine".modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen4
          ./hosts/capucine
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
