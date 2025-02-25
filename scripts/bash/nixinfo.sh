#!/usr/bin/env bash
# nixinfo.sh - Display information about the current NixOS configuration

# Colors for better readability
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

echo -e "${BLUE}╔══════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║         ${YELLOW}NixOS Configuration         ${BLUE}║${RESET}"
echo -e "${BLUE}╚══════════════════════════════════════╝${RESET}"
echo

# System information
echo -e "${YELLOW}System Information:${RESET}"
echo -e "  Hostname: $(hostname)"
echo -e "  Hardware: $(hostnamectl | grep "Hardware Vendor" | cut -d: -f2- | xargs)"
echo -e "  NixOS:    $(nixos-version)"
echo -e "  Kernel:   $(uname -r)"
echo -e "  Uptime:   $(uptime -p | sed 's/up //')"
echo

# Current generation
echo -e "${YELLOW}NixOS Generation:${RESET}"
sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -n 1
echo

# Active configuration
echo -e "${YELLOW}Active Configuration:${RESET}"
readlink -f /run/current-system | sed "s|/nix/store/||" | cut -d- -f1 | head -c 8
echo

# Installed packages count
echo -e "${YELLOW}Package Information:${RESET}"
PACKAGES=$(ls -1 /run/current-system/sw/bin | wc -l)
echo -e "  Binaries:   $PACKAGES"
echo

# Show disk usage
echo -e "${YELLOW}Disk Usage:${RESET}"
df -h / | tail -n 1 | awk '{print "  Root:       " $3 " / " $2 " (" $5 " used)"}'
df -h /nix | tail -n 1 | awk '{print "  Nix Store:  " $3 " / " $2 " (" $5 " used)"}'
echo

# Show RAM usage
echo -e "${YELLOW}Memory Usage:${RESET}"
free -h | grep "Mem:" | awk '{print "  RAM:        " $3 " / " $2 " (" int($3/$2*100) "% used)"}'
echo

# Show network interfaces
echo -e "${YELLOW}Network Interfaces:${RESET}"
ip -br addr | grep -v "lo" | awk '{print "  " $1 ": " $3}'
echo

echo -e "${BLUE}══════════════════════════════════════════${RESET}"
