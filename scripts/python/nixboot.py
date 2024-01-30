#!/usr/bin/env python3

# File paths
source_file = "/etc/nixos/configuration.nix.old"
target_file = "/etc/nixos/boot.nix"

# Read lines starting with "boot.loader" from source file
with open(source_file, "r") as source:
    boot_loader_lines = [line.strip() + '\n' for line in source if line.strip().startswith("boot.loader")]

# Read target file content
with open(target_file, "r") as target:
    target_lines = target.readlines()

# Insert the boot.loader lines into target file at line 13
target_lines = target_lines[:12] + boot_loader_lines + target_lines[12:]

# Write the modified content back to target file
with open(target_file, "w") as target:
    target.writelines(target_lines)

print("Boot loader lines copied and inserted successfully.")

