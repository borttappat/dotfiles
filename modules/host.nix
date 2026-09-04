{ config, lib, pkgs, ... }:
{

imports = [ ./guest-agents.nix ];

# configuration.nix sets networking.hostName = "nix" at plain priority, so
# mkDefault here would lose to it; mkForce is this repo's existing convention
# for a machine-specific hostname override.
networking.hostName = lib.mkForce "host";

}
