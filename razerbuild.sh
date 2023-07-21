#!/run/current-system/sw/bin/bash

# To be tested

# Run the razerconf script to add the contents of razerconf.txt
razerconf.sh

# Rebuild with the modified configuration.nix
sudo nixos-rebuild switch

# Restore the configuration.nix from Git
git pull configuration.nix

echo "razerconfig built"
