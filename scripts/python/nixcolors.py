#!/usr/bin/env python3
import os

def main():
    input_file = os.path.expanduser("~/dotfiles/wal/nix-colors")
    output_file = os.path.expanduser("~/dotfiles/modules/colors.nix")

    # Read the content of nix-colors
    with open(input_file, 'r') as f:
        nix_colors_content = f.readlines()

    # Read the original content of colors.nix
    with open(output_file, 'r') as f:
        original_content = f.readlines()

    # Modify the original content with the content of nix-colors
    modified_content = original_content[:6] + nix_colors_content

    # Add expected end-of-file brackets
    modified_content.extend(['];\n', "}\n"])

    # Write the modified content to colors.nix
    with open(output_file, 'w') as f:
        f.writelines(modified_content)

    print("Updated colors.nix file with the content from nix-colors")

if __name__ == "__main__":
    main()

