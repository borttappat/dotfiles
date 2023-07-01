#!/run/current-system/sw/bin/bash

# Check if the file path argument is provided
    if [ -z "$1" ]; then
      echo "Usage: ./script.sh /path/to/file"
      exit 1
    fi

    # Extract specific part of the path using parameter expansion
    file_path="$1"
    file_name="${file_path##*/}"
    directory="${file_path%/*}"

    # Print the extracted parts of the path
    echo "File path: $file_path"
    echo "File name: $file_name"
    echo "Directory: $directory"


wal -i ${file_path}

HEX_CODE=$(sed -n '2p' ~/.cache/wal/colors | sed 's/#//')
openrgb --device 0 --mode static --color ${HEX_CODE/#/}