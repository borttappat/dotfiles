#!/usr/bin/env python3
import os
import argparse

def is_valid_file_path(path):
    return os.path.isfile(path)

parser = argparse.ArgumentParser(description='Create symbolic links for files and directories.')
parser.add_argument('--file', metavar='file_path', type=str, required=True,
                    help='absolute file path to be linked')
parser.add_argument('--dir', metavar='dir_path', type=str, required=True,
                    help='directory to link the file')
args = parser.parse_args()

# Check if the directory path exists, create it if it doesn't
dir_path = os.path.join(os.getcwd(), args.dir)
if not os.path.isdir(dir_path):
    os.makedirs(dir_path)

# Manually expand tilde in the file path
file_path = os.path.abspath(os.path.expanduser(args.file))

# Remove any existing file in the directory with the same name as the file being linked
link_path = os.path.join(dir_path, os.path.basename(file_path))
if os.path.exists(link_path):
    os.remove(link_path)

# Create link
os.link(file_path, link_path)

