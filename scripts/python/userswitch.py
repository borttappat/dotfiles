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

def get_real_user():
    return os.environ.get('SUDO_USER') or os.getlogin()

def get_user_home(username):
    return pwd.getpwnam(username).pw_dir

# Get the real user (even when run with sudo)
real_user = get_real_user()
user_home = get_user_home(real_user)

# Get user and group IDs
user_info = pwd.getpwnam(real_user)
uid = user_info.pw_uid
gid = user_info.pw_gid

# Directories containing the files to process
dotfiles_directory = os.path.join(user_home, "dotfiles")
nixos_directory = "/etc/nixos"

# List of files to process in dotfiles
dotfiles_list = [
    "modules/configuration.nix",
    "modules/users.nix",
    # Add more dotfiles as needed
]

# List of files to process in /etc/nixos
nixos_files = [
    "configuration.nix",
    "hardware-configuration.nix",
    # Add more NixOS files as needed
]

# Process dotfiles
for file_name in dotfiles_list:
    file_path = os.path.join(dotfiles_directory, file_name)
    if os.path.exists(file_path):
        replace_text_in_file(file_path, "traum", real_user)
        print(f"Replaced 'traum' with '{real_user}' in {file_path}")
    else:
        print(f"File not found: {file_path}")

# Process NixOS files
for file_name in nixos_files:
    file_path = os.path.join(nixos_directory, file_name)
    if os.path.exists(file_path):
        replace_text_in_file(file_path, "traum", real_user)
        print(f"Replaced 'traum' with '{real_user}' in {file_path}")
    else:
        print(f"File not found: {file_path}")

print("Username updated in dotfiles and NixOS configuration.")

# Change ownership of dotfiles to the real user
try:
    subprocess.run(['chown', '-R', f"{real_user}:{real_user}", dotfiles_directory], check=True)
    print(f"Changed ownership of all files in {dotfiles_directory} to {real_user}")
except subprocess.CalledProcessError as e:
    print(f"Error changing ownership: {e}")

print("Process completed.")
