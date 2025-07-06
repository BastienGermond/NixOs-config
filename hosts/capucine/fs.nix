{...}: {
  # Swap configuration
  boot.kernel.sysctl = {
    "vm.swappiness" = 99; # Don't use swap unless really necessary
  };
}
