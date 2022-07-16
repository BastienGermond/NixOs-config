# vim:shiftwidth=2
{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    flake-utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nvim-flake = { url = "github:neovim/neovim?dir=contrib"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dns = { url = "github:kirelagin/dns.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
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
    , ...
    } @ inputs:
    flake-utils.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [ "x86_64-linux" ];

      hostDefaults = {
        modules = [
          ./modules/nix.nix
          ./modules/ssh.nix
        ];
      };

      sharedOverlays = [
      ];

      channelsConfig.allowUnfree = true;

      # channels.nixpkgs.input = nixpkgs-unstable;

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
          ./hosts/synapze-pc/system
          ./home
          ./modules
          ./modules/xorg.nix
          home-manager.nixosModule
        ];

        "anemone".modules = [
          ./hosts/anemone
          ./home
          ./modules
          home-manager.nixosModule
        ];

        "coral".modules = [
          ./hosts/coral
          ./home
          ./modules
          home-manager.nixosModule
        ];
      };

      formatter.x86_64-linux = self.pkgs.x86_64-linux.nixpkgs.nixpkgs-fmt;
    };
}
