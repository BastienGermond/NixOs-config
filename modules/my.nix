{
  config,
  pkgs,
  infra,
  lib,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkDefault mkIf mkMerge types;

  my = config.my;

  mkEnabledByDefaultIfOption = cond: purpose:
    mkOption {
      type = types.bool;
      description = "Whether to enable ${builtins.toString purpose}.";
      default = cond;
    };

  mkEnabledByDefaultOption = mkEnabledByDefaultIfOption true;
in {
  options.my = {
    hostname = mkOption {
      type = types.str;
      description = "Machine hostname.";
    };

    networking = {
      wirelessInterfaces = mkOption {
        type = types.listOf types.str;
        description = "Wireless card interfaces";
        default = [];
      };

      enableFirewall = mkEnableOption "firewall";

      extraAllowedTCPPorts = mkOption {
        type = types.listOf types.int;
        description = "Extra allowed tcp ports";
        default = [];
      };
    };

    isAServer = mkOption {
      type = types.bool;
      description = "Machine is a server.";
      default = false;
    };

    mainUser = mkOption {
      type = types.str;
      description = "Machine main user.";
      default = "bastien";
    };

    timeZone = mkOption {
      type = types.str;
      description = "Machine timezone.";
      default = "Europe/Paris";
    };

    color = mkOption {
      type = types.enum ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"];
      description = "Machine color (hostname in zsh).";
      default = "blue";
    };

    shell = mkOption {
      type = types.package;
      default = pkgs.zsh;
    };

    helix = {
      enable = mkEnabledByDefaultOption "Helix support";

      language-servers = mkOption {
        type = types.listOf types.str;
        name = "List of pre-configured language-server to add";
        default = ["nixd"];
      };
    };

    i3 = {
      enable = mkEnabledByDefaultIfOption (!my.isAServer) "i3 basic configuration with polybar";

      dunst.enable = mkEnabledByDefaultIfOption my.i3.enable "Dunst support";
    };

    alacritty.enable = mkEnabledByDefaultIfOption my.i3.enable "Alacritty support";

    enableDocker = mkEnableOption "Docker support";
    enableVirtualBox = mkEnableOption "VirtualBox support";
    enableInfraVpn = mkEnableOption "my Infrastructure VPN";
  };

  config = mkMerge [
    {
      networking = {
        hostName = my.hostname;
        nameservers = ["1.1.1.1" "8.8.8.8"];
        wireguard.interfaces = mkIf my.enableInfraVpn infra.hosts.${my.hostname}.wireguard;
        networkmanager.enable = mkDefault (!my.isAServer);
        enableIPv6 = true;
        interfaces = mkMerge [
          (builtins.foldl' (acc: name: acc // {${name}.useDHCP = true;}) {} my.networking.wirelessInterfaces)
        ];

        firewall = {
          enable = my.networking.enableFirewall;
          allowedTCPPorts = my.networking.extraAllowedTCPPorts;
        };

        nat = {
          internalInterfaces = mkMerge [
            (mkIf my.enableInfraVpn (builtins.attrNames infra.hosts.${my.hostname}.wireguard))
          ];
        };
      };

      time.timeZone = my.timeZone;

      users.users."${my.mainUser}" = {
        isNormalUser = true;
        uid = 1000;
        home = mkDefault "/home/${my.mainUser}";
        shell = my.shell;
        extraGroups = ["wheel"];
      };

      programs.ssh = {
        startAgent = true;
      };

      # Fonts use in my dunst configuration
      fonts.packages = mkMerge [
        (mkIf my.i3.dunst.enable [pkgs.nerd-fonts.fira-code])
      ];

      # Required to use smart card mode (CCID)
      services.pcscd.enable = true;
      services.yubikey-agent.enable = true;

      services.fwupd.enable = true;

      # Manage backlight without xserver
      # e.g light -U 30 (darker) light -A 30 (lighter)
      programs.light.enable = true;

      services.actkbd = {
        enable = true;
        bindings = [
          # Brightness keys
          {
            keys = [224];
            events = ["key"];
            command = "/run/current-system/sw/bin/light -U 10";
          }
          {
            keys = [225];
            events = ["key"];
            command = "/run/current-system/sw/bin/light -A 10";
          }
        ];
      };

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = false;
        enableBrowserSocket = true;
        pinentryPackage = pkgs.pinentry-curses;
      };

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;

      environment.systemPackages = mkMerge [
        (mkIf my.helix.enable [pkgs.helix])
      ];

      environment.pathsToLink =
        mkMerge
        [
          (mkIf (my.shell == pkgs.zsh) ["/share/zsh"])
        ];

      programs.zsh.enable = mkDefault (pkgs.zsh == my.shell);

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.inputMethod.enable = true;
      i18n.inputMethod.type = "ibus";

      documentation = {
        enable = true;
        info.enable = true;
        doc.enable = true;
        dev.enable = mkDefault (!my.isAServer);
        nixos.enable = mkDefault (!my.isAServer);

        man = {
          enable = true;
          generateCaches = true;
        };
      };
    }

    (mkIf my.i3.enable {
      # Enable the X11 windowing system.
      services.xserver = {
        enable = true;
        videoDrivers = ["modesetting"];
        xkb = {
          layout = "us";
          variant = "alt-intl";
        };
        windowManager.i3 = {
          enable = true;
          extraPackages = with pkgs; [
            i3lock
            polybarFull
            at-spi2-core
          ];
        };
      };

      services.displayManager.autoLogin = {
        enable = mkDefault (!my.isAServer);
        user = my.mainUser;
      };

      services.libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          tappingDragLock = false;
          accelSpeed = "1.5";
        };
      };

      programs.nm-applet = {
        enable = true;
        indicator = true;
      };

      programs.slock.enable = true;

      # Enable for Nautilus https://nixos.wiki/wiki/Nautilus
      services.gvfs.enable = true;
    })

    (mkIf config.networking.networkmanager.enable {
      # This service hang until timeout for 1min at each switch, disabling it temporarily until a
      # better solution is found. (https://github.com/NixOS/nixpkgs/issues/180175)
      systemd.services.NetworkManager-wait-online.enable = false;

      users.users.${my.mainUser}.extraGroups = ["networkmanager"];
    })

    (mkIf my.enableDocker {
      virtualisation.docker.enable = true;
    })

    (mkIf my.enableVirtualBox {
      virtualisation.virtualbox.host.enable = true;

      users.extraGroups.vboxusers.members = ["user-with-access-to-virtualbox"];
      users.users.${my.mainUser}.extraGroups = ["vboxusers"];
    })

    (mkIf my.alacritty.enable {
      environment.variables.TERM = "alacritty";
    })
  ];
}
