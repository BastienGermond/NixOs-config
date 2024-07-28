# List all available targets
list:
    just --list

# Run nixos-rebuild switch on current system
switch:
    nixos-rebuild --use-remote-sudo switch

# Deploy configuration for `hostname`
deploy hostname:
    deploy .#{{hostname}}
