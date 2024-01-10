{
  deploy-rs,
  nixosConfigurations,
}: let
  nodeCfg = [
    {
      hostname = "10.100.10.2";
      name = "anemone";
    }
    {
      hostname = "135.181.36.15";
      name = "coral";
      sshOpts = ["-p" "2222"];
    }
  ];

  createNode = {
    hostname,
    name,
    ...
  } @ extra: {
    name = "${name}";
    value = {
      hostname = "${hostname}";

      sshUser = "synapze";
      sshOpts =
        ["-A"]
        ++ (
          if (builtins.hasAttr "sshOpts" extra)
          then extra.sshOpts
          else []
        );
      magicRollback = false;

      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations.${name};
      };
    };
  };
in {
  nodes = builtins.listToAttrs (builtins.map createNode nodeCfg);

  buildNodes = nodes: (builtins.listToAttrs (builtins.map createNode nodes));

  defaultNodes = nodeCfg;
}
