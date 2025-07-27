# My NixOS configuration

## Hosts

- **nautilus**: Framework 13 AI 300 Series.
- **coral**: VPS hosted within [Hetzner (referral
  link)](https://hetzner.cloud/?ref=R6XfWTfBuoF5), used as a vpn server and
  public ip endpoint for my infrastructure.
- **anemone**: Storage server and hosts "heavy" services.
- _kelp_: currently not setup but will be my desktop computer at some point.

## Secrets

Secrets are handled with [sops-nix](https://github.com/Mic92/sops-nix).

### Update secrets

`sops <file>`

## Build

`nix build .\#nixosConfigurations.<hostname>.config.system.build.toplevel`

## Deployment

Remote deployment uses [deploy-rs](https://github.com/serokell/deploy-rs).

Node configurations are stored in [nodes.nix](/nodes.nix).
