#!/usr/bin/env python3
from importlib.metadata import distributions
from pathlib import Path

def generate_requirements():
    """
    Generate requirements.txt using importlib.metadata,
    which is part of Python's standard library since Python 3.8
    """
    try:
        # Get all installed distributions
        requirements = [
            f"{dist.metadata['Name']}=={dist.version}"
            for dist in distributions()
        ]
        
        # Sort requirements alphabetically
        requirements.sort()
        
        # Write to requirements.txt
        output_file = Path('requirements.txt')
        output_file.write_text('\n'.join(requirements) + '\n')
        print(f"Generated requirements.txt with {len(requirements)} packages")
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    generate_requirements()
