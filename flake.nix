{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = {self, nixpkgs, home-manager, ...} @ inputs: {
    nixosConfigurations = {
      "synapze-pc" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ inputs.neovim-nightly-overlay.overlay ]; })
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.synapze = import ./users/synapze.nix;
            home-manager.users.root = import ./users/root.nix;
          }
        ];
      };
    };

    synapze-pc = self.nixosConfigurations.synapze-pc.config.system.build.toplevel;
  };
}
