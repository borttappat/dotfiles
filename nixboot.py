#!/usr/bin/env python3
import os

# Define the file paths
old_config_path = '/etc/nixos/configuration.nix.old'
new_config_path = '/etc/nixos/configuration.nix'

# Function to extract lines starting with "boot" from a file
def extract_boot_lines(file_path):
    boot_lines = []
    with open(file_path, 'r') as file:
        for line in file:
            if line.strip().startswith("boot"):
                boot_lines.append(line)
    return boot_lines

# Function to write lines to a file starting from a specific line
def write_lines_to_file(file_path, lines, start_line):
    with open(file_path, 'r') as file:
        content = file.readlines()

    # Insert the lines at the specified position
    content[start_line:start_line] = lines

    with open(file_path, 'w') as file:
        file.writelines(content)

# Extract boot lines from the old configuration
boot_lines = extract_boot_lines(old_config_path)

# Read the new configuration to determine where to insert the boot lines
with open(new_config_path, 'r') as file:
    new_config_content = file.readlines()

# Remove existing boot lines in the new configuration
new_config_content = [line for line in new_config_content if not line.strip().startswith("boot")]

# Find the line position of the last "boot" line in the new configuration
last_boot_line_position = -1
for i, line in enumerate(new_config_content):
    if line.strip().startswith("boot"):
        last_boot_line_position = i

if last_boot_line_position >= 0:
    # Append boot lines after the last "boot" line in the new configuration
    write_lines_to_file(new_config_path, boot_lines, start_line=last_boot_line_position + 1)
    print("Lines moved to the new configuration.")
else:
    print("No lines starting with 'boot' found in the old configuration or new configuration.")

