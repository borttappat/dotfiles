#!/usr/bin/env python3

import os
import argparse
import sys
from pathlib import Path

def backup_existing_file(target_path, verbose=False, quiet=False):
    """
    Handles backing up of existing files by renaming to .old
    Only creates a backup if no .old backup already exists
    Returns True if backup was needed/performed, False otherwise
    """
    if not target_path.exists():
        return False
        
    backup_path = target_path.with_suffix(target_path.suffix + '.old')
    
    try:
        if backup_path.exists():
            target_path.unlink()
            if verbose and not quiet:
                print(f"  Preserved existing backup for {target_path.name}")
        else:
            target_path.rename(backup_path)
            if verbose and not quiet:
                print(f"  Created backup: {backup_path.name}")
        return True
    except (OSError, PermissionError) as e:
        if not quiet:
            print(f"  Warning: Could not backup {target_path.name}: {e}")
        return False

def create_hard_link(source_path, target_dir, verbose=False, quiet=False):
    """
    Creates a hard link while preserving existing files as .old backups
    Falls back to symlink if hard linking fails
    """
    source = Path(source_path).expanduser().resolve()
    target_dir = Path(target_dir).expanduser().resolve()
    
    if not source.is_file():
        if not quiet:
            print(f"Error: Source file '{source}' does not exist or is not a file")
        return False
    
    try:
        target_dir.mkdir(parents=True, exist_ok=True)
    except PermissionError as e:
        if not quiet:
            print(f"Error: Cannot create directory {target_dir}: {e}")
        return False
    
    target = target_dir / source.name
    
    if verbose and not quiet:
        print(f"  Linking: {source.name}")
    
    backup_existing_file(target, verbose, quiet)
    
    try:
        os.link(str(source), str(target))
        if verbose and not quiet:
            print(f"  Created hard link: {target}")
        return True
    except OSError:
        try:
            os.symlink(str(source), str(target))
            if verbose and not quiet:
                print(f"  Created symlink: {target}")
            return True
        except OSError as e:
            if not quiet:
                print(f"Error linking {source.name}: {e}")
            return False

def main():
    parser = argparse.ArgumentParser(
        description='Create hard links (with symlink fallback) while preserving existing files as .old backups'
    )
    parser.add_argument('--file', metavar='file_path', type=str, required=True,
                        help='path to file to be linked')
    parser.add_argument('--dir', metavar='dir_path', type=str, required=True,
                        help='directory to link the file to')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='show detailed output for each operation')
    parser.add_argument('-q', '--quiet', action='store_true',
                        help='suppress all output except errors')
    
    args = parser.parse_args()
    
    if args.verbose and args.quiet:
        print("Warning: Both --verbose and --quiet specified, using --quiet")
    
    success = create_hard_link(args.file, args.dir, args.verbose, args.quiet)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
