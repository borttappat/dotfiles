#!/usr/bin/env python3
import os

# Define the lines to add
line1 = "services.xserver.displayManager.startx.enable = true;"
line2 = "services.xserver.windowManager.i3.enable = true;"
line3 = "services.xserver.enable = true;"

# Relic below, ignore
# Set user_home variable to make script user-agnostic
user_home = os.path.expanduser("~")

#file_path = os.path.join(user_home, "etc/nixos/configuration.nix")
file_path = "/etc/nixos/configuration.nix"
#file_path = os.path.join(user_home, "test/testfile.txt")

# Open the input file for reading
with open(file_path, "r") as file:
    lines = file.readlines()

# Open the same file for writing, which will clear its contents
with open(file_path, "w") as file:
    replace_next_lines = False

    for line in lines:
        # Check if the line starts with "services.xserver"
        if line.startswith("services.xserver."):
            replace_next_lines = True
        elif replace_next_lines:
            # Replace the line with the new lines
            file.write(line1 + "\n")
            file.write(line2 + "\n")
            file.write(line3 + "\n")
            replace_next_lines = False
        else:
            # If not, write the line back to the file
            file.write(line)

print("Lines starting with 'services.xserver' replaced with new lines successfully in /etc/nixos/configuration.nix")
