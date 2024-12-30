{
  lib,
  infra,
  config,
  pkgs,
  ...
}: let
  anemone = infra.hosts.anemone;

  baseImmichConfig = "/run/immich";
  immichConfigPath = "${baseImmichConfig}/immich.config.json";

  rawConfig = pkgs.writeText "immich.config.json" (
    builtins.toJSON (import ./immich.config.nix {})
  );
in {
  # Network manager : Don't manage the containers interfaces
  networking.networkmanager.unmanaged = ["interface-name:ve-*"];

  networking = {
    bridges = {
      immich-br = {
        interfaces = [];
      };
    };

    firewall = {
      allowedTCPPorts = [anemone.ports.immich-server];
    };

    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      enableIPv6 = true;
      externalInterface = "enp8s0";

      extraCommands = ''
        iptables -w -t nat -A nixos-nat-pre -i wg0 -p tcp --dport 9012 -j DNAT --to-destination 192.168.100.11:2283
      '';
    };
  };

  users.groups.immich = {
    gid = 950;
  };

  users.users.immich = {
    name = "immich";
    group = "immich";
    uid = 950;
    isSystemUser = true;
  };

  containers.immich = {
    autoStart = true;
    privateNetwork = true;

    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";

    bindMounts = {
      "/data/immich" = {
        hostPath = "/datastore/immich";
        isReadOnly = false;
      };

      "/data/ImmichOIDCSecret" = {
        hostPath = config.sops.secrets.ImmichOIDCSecret.path;
        isReadOnly = true;
      };

      "/immich.base.config.json" = {
        hostPath = builtins.toString rawConfig;
        isReadOnly = true;
      };
    };

    config = {
      users.users.immich.uid = 950;
      users.groups.immich.gid = 950;

      services.immich = {
        enable = true;
        # package = pkgs.immich-pinned;
        host = "192.168.100.11";
        environment = {
          IMMICH_LOG_LEVEL = "verbose";
          # IMMICH_HOST = lib.mkForce "192.168.100.11";
          IMMICH_CONFIG_FILE = "/immich.config.json";
        };

        mediaLocation = "/data/immich";
      };

      system.activationScripts.immich-config = {
        text = ''
          immichClientSecret=$(< /data/ImmichOIDCSecret)
          ${pkgs.jq}/bin/jq --arg immichClientSecret "$immichClientSecret" '.oauth.clientSecret = $immichClientSecret' /immich.base.config.json > /immich.config.json
          chown immich:immich /immich.config.json
          chmod 440 /immich.config.json
        '';
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [2283];
          allowedUDPPorts = [2283];
        };
      };

      system.stateVersion = "24.11";
    };
  };
}
