#!/usr/bin/env bash

# Ensure the Boxes directory exists
mkdir -p ~/Boxes

# Path to the shell.nix file
SHELL_NIX_PATH="$HOME/dotfiles/shells/netscan.nix"

# Path to the Python script
SCRIPT_PATH="$HOME/dotfiles/scripts/python/netscan.py"

# Ensure the script is executable
chmod +x "$SCRIPT_PATH"

# Run nix-shell and execute the Python script
nix-shell "$SHELL_NIX_PATH" --run "python3 $SCRIPT_PATH"
