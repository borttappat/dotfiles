#!/usr/bin/env python3
import os

# Function to replace text in a file
def replace_text_in_file(file_path, search_text, replace_text):
    with open(file_path, 'r') as file:
        file_content = file.read()
    
    modified_content = file_content.replace(search_text, replace_text)
    
    with open(file_path, 'w') as file:
        file.write(modified_content)

# Get the current user's name
current_user = os.getlogin()

# Directory containing the files to process
directory = "~/dotfiles"  # Use the tilde character to represent the home directory

# Expand the tilde character to the actual home directory path
directory = os.path.expanduser(directory)

# List of files to process (add more as needed)
file_list = [
    "modules/configuration.nix",
    "modules/users.nix",
    # Add more file names as needed
]

for file_name in file_list:
    file_path = os.path.join(directory, file_name)

    # Check if the file exists before attempting to replace text
    if os.path.exists(file_path):
        replace_text_in_file(file_path, "traum", current_user)
        print(f"Replaced 'traum' with '{current_user}' in {file_name}")
    else:
        print(f"File not found: {file_name}")

print("Username updated.")

