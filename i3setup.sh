#!/run/current-system/sw/bin/bash

# Define the lines to add
line1 = "services.xserver.displayManager.startx.enable = true;"
line2 = "services.xserver.windowManager.i3.enable = true;"
line3 = "services.xserver.enable = true;"


# Define the file path
file_path="/etc/nixos/configuration.nix"

# Temporary file for storing modified content
temp_file="/etc/configuration_temp.nix"

# Flag to keep track of whether lines have been replaced
lines_replaced=false

# Read the input file line by line
while IFS= read -r line; do
    if [[ $line == *"services.xserver."* ]]; then
        # Replace the line with the new lines
        echo "$line1" >> "$temp_file"
        echo "$line2" >> "$temp_file"
        echo "$line3" >> "$temp_file"
        lines_replaced=true
    else
        # If not, write the line back to the temporary file
        echo "$line" >> "$temp_file"
    fi
done < "$file_path"

# Check if the lines were replaced or not
if $lines_replaced; then
    # Replace the original file with the temporary file
    mv "$temp_file" "$file_path"
    echo "Lines starting with 'services.xserver' replaced with new lines successfully in $file_path."
else
    echo "Original lines not found in $file_path."
    rm -f "$temp_file"  # Remove the temporary file if no replacements were made
fi

