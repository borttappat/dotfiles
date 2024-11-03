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
[Tested with sample words]
- Generate password variations from base words
- Supports basic/advanced complexity levels
- Memory-efficient streaming mode for large lists(AI assisted, ngl)

### Wordlist Trimmer (trim.py)
- Filter wordlists based on complexity rules(static for now, might update further down the line)
- Running a list through the script will ensure the output list has:
  - At least one number
  - At least one special character 
  - Longer than 7 characters

[To do]
- Make the trimming modular instead of static

## Work in progress
### Scanner (scanner.py + vulnscan.py) 
[Still work in progress, currently broken - don't run]
- Network and web service reconnaissance tool
- Combines nmap, whatweb, and searchsploit
- Creates a vulnerability report based on discovered services by nmap and whatweb

[To do]
- Filter the output of nmap and make sure they match the expected format of the searchsploit-scan
- Perform further tests

## Requirements

Uses Nix for dependency management. Required packages(included in shell.nix):
- Python 3.8+
- nmap
- whatweb
- exploitdb (searchsploit)
- Python packages:
  - python-nmap
  - paramiko
  - prompt-toolkit

### Tested on NixOS 24.11

## Setup

1. Install Nix package manager [optional]
2. Clone repository
3. Enter development shell(or just run ```pip install -r requirements.txt```)
```bash
nix-shell
```
The provided ```requirements.txt``` should be enough to get the scripts running without using Nix

## Usage Examples
The ```-h``` flag can be used for each script to output it's proper usage

### SSH Runner
```bash
./ssh.py target.com -u username -s script.sh
./ssh.py IPADDR -u root -s /path/to/script -k id_rsa -n

```

### Wordlist Generator
```bash
# From comma-separated words
./wlgen.py -w password,admin,secret -o wordlist.txt

# From input file
./wlgen.py -l base_words.txt -o wordlist.txt --complexity advanced
./wlgen.py -l griefhound_pass.txt -o griefhound_pass_mut.txt --stream

```

### Wordlist Trimmer
```bash
./trim.py input_wordlist.txt -o filtered_wordlist.txt
```

### Scanner [Broken, don't run]
```bash
sudo python scanner.py target.com
sudo python scanner.py IPADDR
```
