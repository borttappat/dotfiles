```
.-----.--------.---.-.-----.-----.-----.----.
|     |        |  _  |  _  |  _  |  -__|   _|
|__|__|__|__|__|___._|   __|   __|_____|__|
                     |__|  |__|
```
Simple python script to run nmap scans. 
run the scan with ``sudo`` or as ``root`` to use the OS detection scan 
Developed using Nix, shell.nix is the only tested and verified way of running the script.

See requirements.txt

## Functionality

1. **Basic scan options**
    - Scripts
    - Version scan
    - OS Detection

2. **IP list parsing**
    - Run the scan using a list of IPs

3. **Output saving**
    - Save the output as a text file using HH:MM timestamp

