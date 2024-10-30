#!/usr/bin/env python3
import argparse
import re
from pathlib import Path

def get_output_filename(input_file: str) -> str:
    """Generate output filename by adding '_trimmed' before the extension"""
    path = Path(input_file)
    return str(path.with_name(f"{path.stem}_trimmed{path.suffix}"))

def trim_wordlist(input_file: str, output_file: str) -> None:
    """
    Trim wordlist according to specified rules:
    1. Must contain at least one number
    2. Must contain at least one special character
    3. Must be longer than 7 characters
    """
    # Read input file
    with open(input_file, 'r') as f:
        words = f.readlines()

    # Apply filters
    filtered_words = []
    for word in words:
        word = word.strip()
        
        # Skip if shorter than 8 characters
        if len(word) <= 7:
            continue
            
        # Skip if no numbers present
        if not any(char.isdigit() for char in word):
            continue
            
        # Skip if no special characters present
        if not re.search(r'[!-/:-@\[-`{-~]', word):
            continue
            
        filtered_words.append(word)

    # Write output file
    with open(output_file, 'w') as f:
        for word in filtered_words:
            f.write(word + '\n')

def main():
    parser = argparse.ArgumentParser(description='Trim wordlist based on specific criteria')
    parser.add_argument('input_file', help='Input wordlist file')
    parser.add_argument('-o', '--output', help='Output file (defaults to inputname_trimmed.txt)',
                       default=None)
    
    args = parser.parse_args()
    
    # Check if input file exists
    input_path = Path(args.input_file)
    if not input_path.exists():
        print(f"Error: Input file '{args.input_file}' not found")
        return
    
    # Determine output filename
    output_file = args.output if args.output else get_output_filename(args.input_file)
    
    # Process the wordlist
    trim_wordlist(args.input_file, output_file)
    print(f"Processed wordlist saved to {output_file}")

if __name__ == '__main__':
    main()
