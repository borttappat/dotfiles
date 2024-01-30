#!/usr/bin/env python3

import os
import argparse

parser = argparse.ArgumentParser(description='Create symbolic links for files and directories.')
parser.add_argument('--files', metavar='file1,file2,file3', type=str, required=True,
                        help='comma-separated list of files to be linked')
parser.add_argument('--dirs', metavar='dir1,dir2,dir3', type=str, required=True,
                        help='comma-separated list of directories to link the files')
args = parser.parse_args()

files = args.files.split(",")
dirs = args.dirs.split(",")

for i in range(len(files)):
    file_path = os.path.join(os.getcwd(), files[i])

    # Check if the directory path exists, create it if it doesn't
    dir_path = os.path.join(os.getcwd(), dirs[i])
    if not os.path.isdir(dir_path):
        os.makedirs(dir_path)

    # Remove any existing file in the directory with same name as the file being linked
    link_path = os.path.join(dir_path, files[i])
    if os.path.exists(link_path):
        os.remove(link_path)

    # Create the symbolic link
    os.link(file_path, link_path)
