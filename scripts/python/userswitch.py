#!/usr/bin/env python3
import os
import pwd
import grp
import subprocess

def replace_text_in_file(file_path, search_text, replace_text):
    with open(file_path, 'r') as file:
        file_content = file.read()
    
    modified_content = file_content.replace(search_text, replace_text)
    
    with open(file_path, 'w') as file:
        file.write(modified_content)

def change_ownership_recursive(path, uid, gid):
    for root, dirs, files in os.walk(path):
        for dir in dirs:
            os.chown(os.path.join(root, dir), uid, gid)
        for file in files:
            os.chown(os.path.join(root, file), uid, gid)

# Get the current user's name and ID
current_user = os.getlogin()
user_info = pwd.getpwnam(current_user)
uid = user_info.pw_uid
gid = user_info.pw_gid

# Directory containing the files to process
dotfiles_directory = os.path.expanduser("~/dotfiles")

# List of files to process in dotfiles
file_list = [
    "modules/configuration.nix",
    "modules/users.nix",
    # Add more file names as needed
]

# Process dotfiles
for file_name in file_list:
    file_path = os.path.join(dotfiles_directory, file_name)
    if os.path.exists(file_path):
        replace_text_in_file(file_path, "traum", current_user)
        print(f"Replaced 'traum' with '{current_user}' in {file_name}")
    else:
        print(f"File not found: {file_name}")

print("Username updated in dotfiles.")

# Change ownership of all files in home directory
home_directory = os.path.expanduser("~")
try:
    change_ownership_recursive(home_directory, uid, gid)
    print(f"Changed ownership of all files in {home_directory} to {current_user}")
except PermissionError:
    print("Permission denied. Trying with sudo...")
    try:
        subprocess.run(['sudo', 'chown', '-R', f"{current_user}:{current_user}", home_directory], check=True)
        print(f"Changed ownership of all files in {home_directory} to {current_user} using sudo")
    except subprocess.CalledProcessError as e:
        print(f"Error changing ownership: {e}")

print("Process completed.")
