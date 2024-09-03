#!/usr/bin/env python3
import os
import pwd
import subprocess
import sys

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

def change_ownership_recursive(path, owner):
    for root, dirs, files in os.walk(path):
        for dir in dirs:
            dir_path = os.path.join(root, dir)
            subprocess.run(['chown', owner, dir_path], check=True)
            print(f"Changed ownership of directory: {dir_path}")
        for file in files:
            file_path = os.path.join(root, file)
            subprocess.run(['chown', owner, file_path], check=True)
            print(f"Changed ownership of file: {file_path}")

# Get the real user (even when run with sudo)
real_user = get_real_user()
if os.geteuid() == 0 and not os.environ.get('SUDO_USER'):
    print("This script is designed to be run with sudo by a non-root user.")
    print("Please run it as: sudo python3 userswitch.py")
    sys.exit(1)

user_home = get_user_home(real_user)
dotfiles_directory = os.path.join(user_home, "dotfiles")

print(f"Operating on files for user: {real_user}")
print(f"Home directory: {user_home}")

# List of files to process in dotfiles
dotfiles_list = [
    "modules/configuration.nix",
    "modules/users.nix",
    # Add more dotfiles as needed
]

# Process dotfiles
for file_name in dotfiles_list:
    file_path = os.path.join(dotfiles_directory, file_name)
    if os.path.exists(file_path):
        replace_text_in_file(file_path, "traum", real_user)
        print(f"Replaced 'traum' with '{real_user}' in {file_path}")
    else:
        print(f"File not found: {file_path}")

print("Username updated in dotfiles.")

# Change ownership of all files in the home directory to the real user
try:
    change_ownership_recursive(user_home, real_user)
    print(f"Changed ownership of all files and directories in {user_home} to {real_user}")
except subprocess.CalledProcessError as e:
    print(f"Error changing ownership: {e}")
except Exception as e:
    print(f"An unexpected error occurred: {e}")

print("Process completed.")
