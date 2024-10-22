# Crypt.py - Simple keygen, encrypting and decrypting tool

## About
Simple python toolkit with the functionality to generate a key using ```keygen.py``` and then encode/decode files with ```endecrypt.py```


## Usage
```./keygen.py``` generates a key, and will replace an old key with a new key when run multiple times.
```./crypt.py --key OR -k KEY --encrypt OR -e``` followed by a file like ```./crypt.py -k KEY -e message.txt``` encrypts the file ```message.txt```and appends the ```.encrypted``` file extension.

```./crypt.py --key OR -k KEY --decrypt OR -d``` followed by a file like ```./crypt.py -k KEY -d message.txt.encrypted``` decrypts the file and removes the ```.encrypted``` file extension and appends the ```.decrypted``` file extension to the parsed file.

### Information
Tested on NixOS 24.05 using shell.nix. 
```requirements.txt``` was generated using ```generate_requirements.py```, and haven't been thoroughly tested yet.

