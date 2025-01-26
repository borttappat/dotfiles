#!/usr/bin/env python3
# restore.py - Restores .old backup files by removing current version and renaming .old
import os
import argparse
import sys
from pathlib import Path

def restore_backup(directory, filename):
    """
    Restores a .old backup file by removing the current version and renaming .old
    Returns True if successful, False otherwise
    """
    directory = Path(directory).expanduser().resolve()
    current_file = directory / filename
    backup_file = current_file.with_suffix(current_file.suffix + '.old')
    
    # Check if backup exists
    if not backup_file.exists():
        print(f"Error: No backup file found at {backup_file}")
        return False
        
    # Remove current file if it exists
    if current_file.exists():
        current_file.unlink()
        print(f"Removed current file: {current_file}")
    
    # Rename .old back to original
    backup_file.rename(current_file)
    print(f"Restored {backup_file} to {current_file}")
    return True

def main():
    parser = argparse.ArgumentParser(
        description='Restore .old backup files by removing current version and renaming .old')
    parser.add_argument('--dir', metavar='dir_path', type=str, required=True,
                        help='directory containing the files')
    parser.add_argument('--file', metavar='file_name', type=str, required=True,
                        help='name of file to restore (without .old extension)')
    
    args = parser.parse_args()
    
    if not restore_backup(args.dir, args.file):
        sys.exit(1)

if __name__ == "__main__":
    main()
