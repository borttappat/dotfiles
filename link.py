#!/usr/bin/env python3
import os
import argparse

def is_valid_file_path(path):
    return os.path.isfile(path)

parser = argparse.ArgumentParser(description='Create symbolic links for files and directories.')
parser.add_argument('--files', metavar='file1, file2, file3', type=str, required=True,
                    help='comma-separated list of files or file paths to be linked')
parser.add_argument('--dirs', metavar='dir1, dir2, dir3', type=str, required=True,
                    help='comma-separated list of directories to link the files')
args = parser.parse_args()

# Manually expand tilde after parsing arguments
files = [os.path.expanduser(file.strip()) for file in args.files.split(",")]
dirs = [dir.strip() for dir in args.dirs.split(",")]

for file, dir in zip(files, dirs):
    # Check if the directory path exists, create it if it doesn't
    dir_path = os.path.join(os.getcwd(), dir)
    if not os.path.isdir(dir_path):
        os.makedirs(dir_path)

    # Manually expand tilde in the file path
    file_path = os.path.abspath(os.path.expanduser(file))

    # Remove any existing file in the directory with the same name as the file being linked
    link_path = os.path.join(dir_path, os.path.basename(file_path))
    if os.path.exists(link_path):
        os.remove(link_path)

    # Create the symbolic link
    os.symlink(file_path, link_path)

