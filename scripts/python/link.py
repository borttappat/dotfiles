#!/usr/bin/env python3
import os
import argparse
import sys
from pathlib import Path

def backup_existing_file(target_path):
    """
    Handles backing up of existing files by renaming to .old
    Only creates a backup if no .old backup already exists
    Returns True if backup was needed/performed, False otherwise
    """
    if not target_path.exists():
        return False
        
    backup_path = target_path.with_suffix(target_path.suffix + '.old')
    
    # If a .old backup already exists, just remove the current file
    # This preserves the original backup
    if backup_path.exists():
        target_path.unlink()
        print(f"Removed current file: {target_path} (preserved existing backup {backup_path})")
    else:
        # No backup exists yet, so create one
        target_path.rename(backup_path)
        print(f"Backed up existing file to {backup_path}")
    
    return True

def create_link(source_path, target_dir):
    """
    Creates a hard link while preserving existing files as .old backups
    """
    # Convert paths to Path objects for easier manipulation
    source = Path(source_path).expanduser().resolve()
    target_dir = Path(target_dir).expanduser().resolve()
    
    # Validate source file exists
    if not source.is_file():
        print(f"Error: Source file '{source}' does not exist or is not a file")
        sys.exit(1)
    
    # Create target directory if it doesn't exist
    target_dir.mkdir(parents=True, exist_ok=True)
    
    # Construct target path
    target = target_dir / source.name
    
    # Handle existing file backup
    backup_existing_file(target)
    
    try:
        # Create the hard link
        os.link(str(source), str(target))
        print(f"Created link: {target} -> {source}")
    except OSError as e:
        print(f"Error creating link: {e}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        description='Create hard links while preserving existing files as .old backups')
    parser.add_argument('--file', metavar='file_path', type=str, required=True,
                        help='absolute file path to be linked')
    parser.add_argument('--dir', metavar='dir_path', type=str, required=True,
                        help='directory to link the file')
    
    args = parser.parse_args()
    create_link(args.file, args.dir)

if __name__ == "__main__":
    main()
