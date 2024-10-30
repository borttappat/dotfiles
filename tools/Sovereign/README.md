# Security Testing Toolkit

A collection of Python scripts for security testing and reconnaissance.

## Tools

### Scanner (scanner.py)
- Network and web service reconnaissance tool
- Combines nmap, whatweb, and searchsploit
- Creates vulnerability reports based on discovered services

### SSH Runner (ssh.py) 
- Securely upload and execute scripts on remote systems
- Supports password and key-based authentication
- Output capture and local/remote saving

### Wordlist Generator (wlgen.py)
- Generate password variations from base words
- Supports basic/advanced complexity levels
- Memory-efficient streaming mode for large lists

### Wordlist Trimmer (trim.py)
- Filter wordlists based on complexity rules
- Minimum requirements:
  - At least one number
  - At least one special character
  - Longer than 7 characters

## Requirements

Uses Nix for dependency management. Required packages:
- Python 3.8+
- nmap
- whatweb
- exploitdb (searchsploit)
- Python packages:
  - python-nmap
  - paramiko
  - prompt-toolkit

## Setup

1. Install Nix package manager
2. Clone repository
3. Enter development shell:
```bash
nix-shell
```

## Usage Examples

### Scanner
```bash
./scanner.py target.com
```

### SSH Runner
```bash
./ssh.py target.com -u username -s script.sh
```

### Wordlist Generator
```bash
# From comma-separated words
./wlgen.py -w password,admin,secret -o wordlist.txt

# From input file
./wlgen.py -l base_words.txt -o wordlist.txt --complexity advanced
```

### Wordlist Trimmer
```bash
./trim.py input_wordlist.txt -o filtered_wordlist.txt
```

## Security Notice

This toolkit is for authorized security testing only. Always ensure you have permission to test target systems.
