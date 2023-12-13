#!/usr/bin/env python3

import re

# Define the file path
file_path = "/etc/nixos/nixp.nix"

# Define the start and end markers
start_marker = "# Packages parsed with nixp.nix will be parsed below"
end_marker = "];"

# Function to extract lines between markers and sort them
def extract_and_sort_lines(file_path, start_marker, end_marker):
    lines_to_sort = []
    inside_section = False

    # Read the file line by line
    with open(file_path, "r") as file:
        for line in file:
            # Check for the start marker
            if start_marker in line:
                inside_section = True
                continue

            # Check for the end marker
            if end_marker in line and inside_section:
                inside_section = False
                break

            # If inside the section, add the line to the list
            if inside_section:
                lines_to_sort.append(line.strip())

    # Sort the lines alphabetically
    sorted_lines = sorted(lines_to_sort)

    return sorted_lines

# Function to replace unsorted content with sorted content
def replace_unsorted_content(file_path, start_marker, end_marker, sorted_lines):
    inside_section = False
    new_content = []

    # Read the file line by line
    with open(file_path, "r") as file:
        for line in file:
            # Check for the start marker
            if start_marker in line:
                inside_section = True
                new_content.append(line)

                # Add sorted lines with line breaks
                for sorted_line in sorted_lines:
                    new_content.append(f"  {sorted_line};\n")

                continue

            # Check for the end marker
            if end_marker in line and inside_section:
                inside_section = False

            # If outside the section, add the line to the new content
            if not inside_section:
                new_content.append(line)

    # Write the new content back to the file
    with open(file_path, "w") as file:
        file.writelines(new_content)

# Call the functions
sorted_lines = extract_and_sort_lines(file_path, start_marker, end_marker)
replace_unsorted_content(file_path, start_marker, end_marker, sorted_lines)

