#!/run/current-system/sw/bin/bash

# Add unstable channel
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos

# Update with new channel
sudo nix-channel --update
    
# Rebuild 
sudo nixos-rebuild switch --upgrade
