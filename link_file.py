import os
import sys

def main():
    # Get the file name and directory path from command line arguments
    filename = sys.argv[1]
    directory = sys.argv[2]

    # Check if the directory exists, if not, create it
    if not os.path.exists(directory):
        os.makedirs(directory)

    # Check if a file with the same name exists in the directory, if so, delete it
    file_path = os.path.join(directory, filename)
    if os.path.exists(file_path):
        os.remove(file_path)

    # Create a hard link to the directory
    os.link(filename, file_path)

if __name__ == '__main__':
    main()
