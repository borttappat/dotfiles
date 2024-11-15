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
[Edit: added testscript.sh to repo to test with instead of linpeas.sh(has been somewhat unreliable)]
- Uploads and executes a script on remote systems using ssh
- Supports password and key-based authentication
- Output capture and local/remote saving

### Wordlist Generator (wlgen.py)
- Generate password variations from base words
- Supports basic/advanced complexity levels
- Memory-efficient streaming mode for large lists(AI assisted, ngl)

### Wordlist Trimmer (trim.py)
- Filter wordlists based on complexity rules along with minimum and maximum length
- Running a list through the script will ensure the output list has:
  - At least one number
  - At least one special character 
  - Is of minimum length as inputted with ```--min flag```
  - Is of maximum length as inputted with ```--max flag```
- Prints the changes made to the list in terms of word-count
- Example handling: password -> rejected, passw0rd! -> accepted

### Subdomain scanner (subenum.py)
[Tested against hackerone.com and inlanefreight.com]
- Scans the target for subdomains using wordlists and/or sublist3r
- Accepts wordlists for wordlist-based enumeration
- Perfoms passive scans using sublist3r if no wordlist is provided
- Outputs the findings with color codes depending on the result

[To do]
- Combine subdomain enumeration with added vhost enumeration when scanning against targets accessed over VPN 

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
3. Enter development shell or skip to step 4 if just using ```pip```
```bash
nix-shell
```
The provided ```requirements.txt``` should be enough to get the scripts running without using Nix by installing required packages with pip
```bash
pip install -r requirements.txt
```



## Usage Examples
The ```-h``` flag can be used for each script to output it's proper usage

### SSH Runner
Running a script using just a username(will prompt for a password during execution) and a script
```bash
./ssh.py IPADDR -u username -s linpeas.sh
```
Running a script using a key
```bash
./ssh.py IPADDR -u root -s /path/to/script -k id_rsa -n

```


### Wordlist Generator
From comma-separated words
```bash
./wlgen.py -w password,admin,secret -o wordlist.txt
```

From input file, using the "advanced" complexity
```bash
./wlgen.py -l /path/to/base_words_list.txt -o output_wordlist.txt --complexity advanced
```
Using ```--stream``` to store the results to a file instead of storing in memory
```bash
./wlgen.py -l /path/to/base_words_list.txt -o output_wordlist.txt --stream

```


### Wordlist Trimmer
```bash
./trim.py /path/to/wordlist -o output_wordlist.txt --min X --max Y
```


### Keygen
Generate a key(will remove the old key beforehand)
```bash
./keygen.py
```


### Decrypting Tool
Encrypting using the ```-e``` or ```--encrypt``` flag
```bash
./crypt.py -k /path/to/key -e /path/to/file
```

Decrypting using the ```-d``` or ```--decrypt``` flag
```bash
./crypt.py -k /path/to/key -d /path/to/file 
```


### Subdomain Enumeration
Enumerating using just sublist3r, without a wordlist
```bash
./subenum.py google.com -o output_file
```
Enumerating with sublister and a wordlist
```bash
./subenum.py hackerone.com -w /path/to/wordlist -o output_file
```


