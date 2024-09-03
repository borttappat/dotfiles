#!/usr/bin/env python3

import os

# File paths
configuration_nix = "/etc/nixos/configuration.nix"
hardware_configuration_nix = "/etc/nixos/hardware-configuration.nix"
target_file = os.path.expanduser("~/dotfiles/modules/boot.nix")

# Read lines starting with "boot.loader" from configuration.nix
with open(configuration_nix, "r") as source:
    boot_loader_lines = [line.strip() + '\n' for line in source if line.strip().startswith("boot.loader")]

# Read hardware-configuration.nix content
with open(hardware_configuration_nix, "r") as hardware_config:
    hardware_lines = hardware_config.readlines()[8:]  # Start from line 9
    # Find the last occurrence of "}"
    last_brace_index = len(hardware_lines) - next(i for i, line in enumerate(reversed(hardware_lines)) if "}" in line) - 1
    hardware_lines = hardware_lines[:last_brace_index]

# Read target file content
with open(target_file, "r") as target:
    target_lines = target.readlines()

# Find the index of the line containing "# Bootloader"
bootloader_index = next((i for i, line in enumerate(target_lines) if "# Bootloader" in line), -1)

if bootloader_index != -1:
    # Insert the hardware-configuration lines before "# Bootloader"
    # and boot.loader lines after "# Bootloader"
    target_lines = (
        target_lines[:bootloader_index] +
        hardware_lines +
        ["\n"] +  # Add a newline for separation
        target_lines[bootloader_index:bootloader_index + 1] +
        boot_loader_lines +
        target_lines[bootloader_index + 1:]
    )

    # Write the modified content back to target file
    with open(target_file, "w") as target:
        target.writelines(target_lines)

    print("Hardware configuration and boot loader lines copied and inserted successfully.")
else:
    print("Error: '# Bootloader' line not found in the target file.")
