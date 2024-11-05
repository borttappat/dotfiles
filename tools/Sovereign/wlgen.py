#!/usr/bin/env python3
import argparse
from itertools import product
import random
import string
import time
import sys
from pathlib import Path


def generate_variations(word, leet_level="basic"):
    variations = set()

    # List of common replacements for leetspeak in basic mode
    basic_leet = {
        "a": ["@", "4"],
        "e": ["3"],
        "i": ["1"],
        "l": ["1"],
        "o": ["0"],
        "s": ["$"],
        "t": ["7"],
    }
    # List of more "advanced" replacements for leetspeak in advanced mode
    advanced_leet = {
        **basic_leet,
        "b": ["8"],
        "g": ["9"],
        "h": ["#"],
        "z": ["2"],
        "q": ["9"],
        "c": ["("],
    }

    leet_map = advanced_leet if leet_level == "advanced" else basic_leet

    def get_all_cases(word):
        """Generate all possible case combinations of the word"""
        return {
            "".join(
                c.upper() if i & (1 << j) else c.lower() for j, c in enumerate(word)
            )
            for i in range(1 << len(word))
        }

    # Start with case variations
    variations.update(get_all_cases(word))

    # Apply leet speak transformations
    temp_variations = set(variations)
    for variant in temp_variations:
        for char, replacements in leet_map.items():
            if char in variant.lower():
                for replacement in replacements:
                    variations.add(variant.replace(char, replacement))

    return variations


def add_common_suffixes(
    variations, min_length=None, max_length=None, complexity="basic"
):
    result = set()
    current_year = time.localtime().tm_year

    # Enhanced suffix lists
    years = [str(year) for year in range(current_year - 30, current_year + 1)] + [
        str(year)[2:] for year in range(current_year - 30, current_year + 1)
    ]

    basic_special = ["!", "@", "#", "$", "*", "123", "12345"]
    advanced_special = [
        "!",
        "@",
        "#",
        "$",
        "*",
        "&",
        "123",
        "1234",
        "12345",
        "!@#",
        "$%^",
        "&*(",
        "_",
        "-",
        "+",
        "=",
    ]

    special_chars = advanced_special if complexity == "advanced" else basic_special

    # Add common password patterns
    for word in variations:
        result.add(word)

        # Add suffix combinations
        for suffix in years + special_chars:
            new_word = word + suffix
            if (min_length is None or len(new_word) >= min_length) and (
                max_length is None or len(new_word) <= max_length
            ):
                result.add(new_word)

        # Add prefix variations for advanced complexity
        if complexity == "advanced":
            for prefix in special_chars:
                new_word = prefix + word
                if (min_length is None or len(new_word) >= min_length) and (
                    max_length is None or len(new_word) <= max_length
                ):
                    result.add(new_word)

    return result


def estimate_memory_usage(word_count, avg_length=10):
    """Estimate memory usage for the wordlist"""
    avg_variations = 50  # Rough estimate of variations per word
    estimated_size = word_count * avg_variations * avg_length
    return estimated_size / (1024 * 1024)  # Convert to MB


def main():
    parser = argparse.ArgumentParser(
        description="Generate a wordlist with various transformations"
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-w", "--words", help="Comma-separated list of words")
    group.add_argument("-l", "--list", help="File containing list of words")
    parser.add_argument("-min", type=int, help="Minimum password length")
    parser.add_argument("-max", type=int, help="Maximum password length")
    parser.add_argument(
        "-o", "--output", help="Output file name", default="wordlist.txt"
    )
    parser.add_argument(
        "--complexity",
        choices=["basic", "advanced"],
        default="basic",
        help="Complexity level of variations (basic or advanced)",
    )
    parser.add_argument(
        "--memory-check",
        action="store_true",
        help="Estimate memory usage before processing",
    )
    parser.add_argument(
        "--stream",
        action="store_true",
        help="Stream results to file instead of storing in memory",
    )

    args = parser.parse_args()

    # Input validation
    if args.min and args.max and args.min > args.max:
        print("Error: Minimum length cannot be greater than maximum length")
        sys.exit(1)

    # Ensure output directory exists
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Get input words
    words = []
    if args.words:
        words = [w.strip() for w in args.words.split(",") if w.strip()]
    elif args.list:
        try:
            with open(args.list, "r") as f:
                words = [line.strip() for line in f if line.strip()]
        except FileNotFoundError:
            print(f"Error: Input file '{args.list}' not found")
            sys.exit(1)

    if not words:
        print("Error: No valid input words provided")
        sys.exit(1)

    # Memory usage estimation
    if args.memory_check:
        estimated_mb = estimate_memory_usage(len(words))
        print(f"Estimated memory usage: {estimated_mb:.2f} MB")
        if estimated_mb > 1000:  # Warning if over 1GB
            response = input("Warning: High memory usage expected. Continue? (y/n): ")
            if response.lower() != "y":
                sys.exit(0)

    # Process words
    if args.stream:
        # Stream mode - write variations directly to file
        with open(args.output, "w") as f:
            total_variations = 0
            for word in words:
                variations = generate_variations(word, args.complexity)
                variations = add_common_suffixes(
                    variations, args.min, args.max, args.complexity
                )
                for variation in sorted(variations):
                    f.write(variation + "\n")
                total_variations += len(variations)
    else:
        # Memory mode - store all variations before writing
        all_variations = set()
        for word in words:
            variations = generate_variations(word, args.complexity)
            variations = add_common_suffixes(
                variations, args.min, args.max, args.complexity
            )
            all_variations.update(variations)

        # Write results
        with open(args.output, "w") as f:
            for variation in sorted(all_variations):
                f.write(variation + "\n")
        total_variations = len(all_variations)

    print(f"Generated {total_variations} variations in {args.output}")


if __name__ == "__main__":
    main()
