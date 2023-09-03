#!/run/current-system/sw/bin/bash

# Check if there are no arguments
if [ $# -eq 0 ]; then
  echo "Error: Please provide arguments separated by spaces."
  exit 1
fi

# Define the file path
file_path="$HOME/dotfiles/nixp.nix"

# Line number to insert the arguments
line_number=8

# Check if the file exists
if [ ! -e "$file_path" ]; then
  echo "Error: $file_path does not exist."
  exit 1
fi

# Loop through the arguments and insert them at line 8 and increment line_number
for arg in "$@"; do
  sed -i "${line_number}i${arg}" "$file_path"
  ((line_number++))
done

echo "Arguments inserted into $file_path:" 
echo "$@"

# Prompt the user to update the system
read -p "Do you want to update the system? (Y/N): " response
if [[ "$response" == "Y" || "$response" == "y" ]]; then
  
  echo "Updating system..."
  update="sudo nixos-rebuild switch --flake /etc/nixos#traum"
  $update
  #echo "System updated successfully."
else
  echo "No action taken."
fi
