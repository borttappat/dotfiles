```text
                                    __
.-----.-----.--.--.-----.----.-----|__.-----.-----.
|__ --|  _  |  |  |  -__|   _|  -__|  |  _  |     |
|_____|_____|\___/|_____|__| |_____|__|___  |__|__|
                                      |_____|
```
# Security Testing Toolkit

A collection of Python scripts to aid in pentesting/CTF tasks

## Tools

### SSH Runner (ssh.py) 
[Tested with a linpeas-script(provided in this repo, original at https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS)  on a Hack The Box lab host]
- Uploads and executes a script on remote systems using ssh
- Supports password and key-based authentication
- Output capture and local/remote saving

### Wordlist Generator (wlgen.py)
- Generate password variations from base words
- Supports basic/advanced complexity levels
- Memory-efficient streaming mode for large lists(AI assisted, ngl)

### Wordlist Trimmer (trim.py)
- Filter wordlists based on complexity rules(static for now, might update further down the line)
- Running a list through the script will ensure the output list has:
  - At least one number
  - At least one special character 
- Allows for minimum and maximum word lengths
- Prints the changes made to the list in terms of word-count
- Example: password -> rejected, passw0rd! -> acepted

### Subdomain scanner (subenum.py)
[Tested against hackerone.com and inlanefreight.com as well as boxes on Hack The Box; Stocker]
- Scans the target for subdomains using wordlists and/or sublist3r
- Accepts wordlists for wordlist-based enumeration
- Only perfoms passive scans using sublist3r if no wordlist is provided
- Outputs the findings with color codes depending on the result

### Simple keygen, encrypting and derypting suite(crypt.py + keygen.py)
- Generate encryption keys with keygen.py
- Encrypt/decrypt parsed files with crypt.py and a key(remember to use the same key for encryption and deryption)
- Adds file extension based on encrypting or decrypting mode


## Requirements

Uses Nix for dependency management. Required packages(included in shell.nix):
- Python 3.8+
- Python packages:
  - paramiko
  - prompt-toolkit
  - sublist3r
  - cryptography
  - requests
  - urllib3
  - dnspython


### Tested on NixOS 24.11

## Setup

1. Install Nix package manager [optional]
2. Clone repository 
```bash 
git clone https://github.com/borttappat/dotfiles/tree/main/tools/Sovereign
```
3. Enter development shell(or just run ```pip install -r requirements.txt```)
```bash
nix-shell
```
The provided ```requirements.txt``` should be enough to get the scripts running without using Nix by installing required files with pip
```bash
pip install -r requirements.txt
```

## Usage Examples
The ```-h``` flag can be used for each script to output it's proper usage

### SSH Runner
```bash
./ssh.py IPADDR -u username -s linpeas.sh
```

```bash
./ssh.py IPADDR -u root -s /path/to/script -k id_rsa -n

```

### Wordlist Generator
# From comma-separated words
```bash
./wlgen.py -w password,admin,secret -o wordlist.txt
```

# From input file
```bash
./wlgen.py -l base_words.txt -o wordlist.txt --complexity advanced
```

```bash
./wlgen.py -l griefhound_pass.txt -o griefhound_pass_mut.txt --stream

```

### Wordlist Trimmer
```bash
./trim.py input_wordlist.txt -o filtered_wordlist.txt
```

### Keygen
```bash
./keygen.py
```

### Decrypting Tool
```bash
./crypt.py -k KEY -e file
./crypt.py -k keY -d file_encrypted
```

### Subdomain Enumeration
```bash
./subenum.py google.com -o google_subdomains.txt
./subenum.py hackerone.com -w /path/to/wordlist -o hackerone_subdomains.txt
```


