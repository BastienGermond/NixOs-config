{ deploy-rs, nixosConfigurations }:

let
  nodeCfg = [
    {
      hostname = "10.100.10.2";
      name = "anemone";
    }
    {
      hostname = "135.181.36.15";
      name = "coral";
    }
  ];

  createNode = { hostname, name }: {
    name = "${name}";
    value = {
      hostname = "${hostname}";

      sshUser = "synapze";
      sshOpts = [ "-A" ];
      magicRollback = false;
      fastConnection = true;

      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations.${name};
      };
    };
  };
in
{
  nodes = (builtins.listToAttrs (builtins.map createNode nodeCfg));

  buildNodes = nodes: (builtins.listToAttrs (builtins.map createNode nodes));

  defaultNodes = nodeCfg;
}
