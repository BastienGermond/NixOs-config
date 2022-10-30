# vim:shiftwidth=2
{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = { url = "github:nix-community/home-manager/release-22.05"; inputs.nixpkgs.follows = "nixpkgs"; };
    flake-utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nvim-flake = { url = "github:neovim/neovim?dir=contrib"; inputs.nixpkgs.follows = "nixpkgs"; };
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
        inherit deploy-rs; nixosConfigurations =
        self.nixosConfigurations;
      };
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
        extraArgs = { inherit dns; };
      };

      channelsConfig.allowUnfree = true;

      channels.nixpkgs.input = nixpkgs-unstable;

      channels.nixpkgs.overlaysBuilder = channels: [
        (final: prev: {
          # Unstable branch
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};

          # Custom packages
          spotibar = final.callPackage ./pkgs/spotibar/default.nix { };

          go_1_18 = nixpkgs-unstable.legacyPackages.${prev.system}.go_1_18;
          ltex-ls = nixpkgs-unstable.legacyPackages.${prev.system}.ltex-ls;

          neovim = nvim-flake.packages.${prev.system}.neovim;
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
            unstable.deploy-rs
            sops
          ];
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
