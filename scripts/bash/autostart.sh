#!/run/current-system/sw/bin/bash

# Get the hostname from hostnamectl's "Icon name" field
hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)

# Check if hostname contains "vm" (case-insensitive)
if [[ ! $hostname =~ [vV][mM] ]]; then
    # If hostname doesn't contain "vm", run picom
    picom -b
fi
