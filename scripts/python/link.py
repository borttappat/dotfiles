# link.py
#!/usr/bin/env python3
# link.py - Creates hard links while preserving existing files as .old backups
import os
import argparse
import sys
from pathlib import Path

def backup_existing_file(target_path, verbose=False):
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
        if verbose:
            print(f"Preserved existing backup for {target_path.name}")
    else:
        # No backup exists yet, so create one
        target_path.rename(backup_path)
        if verbose:
            print(f"Created new backup: {backup_path.name}")
    
    return True

def create_link(source_path, target_dir, verbose=False):
    """
    Creates a hard link while preserving existing files as .old backups
    """
    # Convert paths to Path objects for easier manipulation
    source = Path(source_path).expanduser().resolve()
    target_dir = Path(target_dir).expanduser().resolve()
    
    # Validate source file exists
    if not source.is_file():
        print(f"Error: Source file '{source}' does not exist or is not a file")
        return False
    
    # Create target directory if it doesn't exist
    target_dir.mkdir(parents=True, exist_ok=True)
    
    # Construct target path
    target = target_dir / source.name
    
    if verbose:
        print(f"Linking: {source.name}")
    
    # Handle existing file backup
    backup_existing_file(target, verbose)
    
    try:
        # Create the hard link
        os.link(str(source), str(target))
        return True
    except OSError as e:
        print(f"Error creating link for {source.name}: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(
        description='Create hard links while preserving existing files as .old backups')
    parser.add_argument('--file', metavar='file_path', type=str, required=True,
                        help='absolute file path to be linked')
    parser.add_argument('--dir', metavar='dir_path', type=str, required=True,
                        help='directory to link the file')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='show detailed output for each operation')
    parser.add_argument('-q', '--quiet', action='store_true',
                        help='show no output except errors')
    
    args = parser.parse_args()
    
    # Verbose overrides quiet if both are specified
    verbose = args.verbose and not args.quiet
    
    success = create_link(args.file, args.dir, verbose)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
