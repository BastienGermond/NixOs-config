# vim:shiftwidth=2
{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    flake-utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager, ...} @ inputs:
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
      inputs.neovim-nightly.overlay
    ];

    channelsConfig.allowUnfree = true;

    # channels.nixpkgs.input = nixpkgs-unstable;

    channels.nixpkgs.overlaysBuilder = channels: [
      (final: prev: {
        go_1_18 = nixpkgs-unstable.legacyPackages.${prev.system}.go_1_18;
        unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      })
    ];

    hosts = {
      "synapze-pc".modules = [
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
  };
}
