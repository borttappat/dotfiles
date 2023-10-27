#!/usr/bin/env python3
import os
import fileinput

# Function to replace text in a file
def replace_text_in_file(file_path, search_text, replace_text):
    with fileinput.FileInput(file_path, inplace=True) as file:
        for line in file:
            print(line.replace(search_text, replace_text), end='')

# User input for replacement text
replace_text = input("Enter the text to replace 'traum' with: ")

# Directory containing the files to process
directory = "~/dotfiles"  # Use the tilde character to represent the home directory

# Expand the tilde character to the actual home directory path
directory = os.path.expanduser(directory)

# List of files to process (add more as needed)
file_list = [
    "configuration.nix",
    "services.nix",
    "users.nix",
    # Add more file names as needed
]

for file_name in file_list:
    file_path = os.path.join(directory, file_name)

    # Check if the file exists before attempting to replace text
    if os.path.exists(file_path):
        replace_text_in_file(file_path, "traum", replace_text)
        print(f"Replaced 'traum' with '{replace_text}' in {file_name}")
    else:
        print(f"File not found: {file_name}")

print("Text replacement completed.")

