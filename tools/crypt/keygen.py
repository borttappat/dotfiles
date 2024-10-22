#!/usr/bin/env python3
from cryptography.fernet import Fernet

#Generate a new Fernet key and save it to a file
def generate_key():
    key = Fernet.generate_key()
    with open("secret.key", "wb") as key_file:
        key_file.write(key)
    print("Key has been generated and saved to 'secret.key'")

if __name__ == "__main__":
    generate_key()
