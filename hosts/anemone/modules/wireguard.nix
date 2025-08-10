{infra, ...}: {
  networking.nat.internalInterfaces = builtins.attrNames infra.hosts.anemone.wireguard;

  # networking.wireguard.interfaces = infra.hosts.anemone.wireguard;
}
