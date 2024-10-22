#!/usr/bin/env python3
import argparse
import os
from cryptography.fernet import Fernet

# take in the key as an argument
def load_key(key_path):
    try:
        return open(key_path, "rb").read()
    except FileNotFoundError:
        raise FileNotFoundError(f"Error: Key file '{key_path}' not found")

def encrypt_file(filename, key_path):
    try:
        # Check for key first
        key = load_key(key_path)
        
        # Check for input file
        if not os.path.exists(filename):
            print(f"Error: File '{filename}' not found.")
            return
            
        f = Fernet(key)
        with open(filename, "rb") as file:
            file_data = file.read()
        encrypted_data = f.encrypt(file_data)
        encrypted_filename = filename + ".encrypted"
        with open(encrypted_filename, "wb") as file:
            file.write(encrypted_data)
        print(f"File '{filename}' has been encrypted to '{encrypted_filename}'")
    except FileNotFoundError as e:
        print(str(e))  
    except Exception as e:
        print(f"An error occurred: {str(e)}")

# Modified to accept key path
def decrypt_file(filename, key_path):
    try:
        # Check for key first
        key = load_key(key_path)
        
        # Check for input file 
        if not os.path.exists(filename):
            print(f"Error: File '{filename}' not found.")
            return
            
        if not filename.endswith('.encrypted'):
            print(f"Error: File '{filename}' does not have .encrypted extension")
            return
        
        f = Fernet(key)
        with open(filename, "rb") as file:
            encrypted_data = file.read()
        decrypted_data = f.decrypt(encrypted_data)
        
        # Remove .encrypted extension for the output file
        decrypted_filename = filename[:-10] + ".decrypted"  

        with open(decrypted_filename, "wb") as file:
            file.write(decrypted_data)
        print(f"File '{filename}' has been decrypted to '{decrypted_filename}'")
    except FileNotFoundError as e:
        print(str(e)) 
    except Exception as e:
        print(f"An error occurred: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description="File encryption/decryption tool")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-e", "--encrypt", action="store_true", help="Encrypt the file")
    group.add_argument("-d", "--decrypt", action="store_true", help="Decrypt the file")
    parser.add_argument("filename", help="Name of the file to process")
    parser.add_argument("-k", "--key", required=True, help="Path to the key file")
    args = parser.parse_args()

    if args.encrypt:
        encrypt_file(args.filename, args.key)
    elif args.decrypt:
        decrypt_file(args.filename, args.key)

if __name__ == "__main__":
    main()
