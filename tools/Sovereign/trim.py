#!/usr/bin/env python3
import argparse
import re
from pathlib import Path

def get_output_filename(input_file: str) -> str:
    """Generate output filename by adding '_trimmed' before the extension"""
    path = Path(input_file)
    return str(path.with_name(f"{path.stem}_trimmed{path.suffix}"))

def count_lines(file_path):
    """Count the number of lines in a file."""
    try:
        with open(file_path, 'r') as f:
            return sum(1 for line in f)
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found")
        return None
    except Exception as e:
        print(f"Error counting lines: {e}")
        return None

def trim_wordlist(input_file: str, output_file: str, min_length: int = None, max_length: int = None) -> None:
    """
    Trim wordlist according to specified rules:
    1. Must contain at least one number
    2. Must contain at least one special character
    3. Must meet length requirements if specified
    """
    # Read input file
    with open(input_file, 'r') as f:
        words = f.readlines()

    initial_count = len(words)

    # Apply filters
    filtered_words = []
    for word in words:
        word = word.strip()
        
        # Skip if shorter than minimum length
        if min_length and len(word) < min_length:
            continue
            
        # Skip if longer than maximum length
        if max_length and len(word) > max_length:
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

    return initial_count, len(filtered_words)

def main():
    parser = argparse.ArgumentParser(description='Trim wordlist based on specific criteria')
    parser.add_argument('input_file', help='Input wordlist file')
    parser.add_argument('-o', '--output', help='Output file (defaults to inputname_trimmed.txt)',
                       default=None)
    parser.add_argument('--min', type=int, help='Minimum word length',
                       default=None)
    parser.add_argument('--max', type=int, help='Maximum word length',
                       default=None)
    
    args = parser.parse_args()
    
    # Input validation
    if args.min and args.max and args.min > args.max:
        print(f"Error: Minimum length ({args.min}) cannot be greater than maximum length ({args.max})")
        return
    
    # Check if input file exists
    input_path = Path(args.input_file)
    if not input_path.exists():
        print(f"Error: Input file '{args.input_file}' not found")
        return
    
    # Determine output filename
    output_file = args.output if args.output else get_output_filename(args.input_file)
    
    # Process the wordlist
    initial_count, final_count = trim_wordlist(args.input_file, output_file, args.min, args.max)
    
    # Print summary
    print(f"\nWordlist Processing Summary:")
    print(f"Input file: {args.input_file} ({initial_count} words)")
    print(f"Output file: {output_file} ({final_count} words)")
    print(f"Removed: {initial_count - final_count} words")
    
    # Print summary of length filters applied
    if args.min or args.max:
        length_rules = []
        if args.min:
            length_rules.append(f">= {args.min} characters")
        if args.max:
            length_rules.append(f"<= {args.max} characters")
        print(f"Applied length filters: {' and '.join(length_rules)}")

if __name__ == '__main__':
    main()
