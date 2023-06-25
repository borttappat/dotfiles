#!/bin/bash

# add unstable channel
nix-channel --add https://nixos.org/channels/nixos-unstable nixos

# Update with new channel
nix-channel --update

# Rebuild with new 
sudo nixos-rebuild switch --upgrade
