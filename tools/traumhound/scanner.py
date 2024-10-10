#!/usr/bin/env python3

import os
import re
import subprocess
import curses
from curses import wrapper
from prompt_toolkit import prompt
from datetime import datetime

def is_root():
    return os.geteuid() == 0

def display_ascii_art(stdscr=None):
    ascii_art = """
 __                             __                         __
|  |_.----.---.-.--.--.--------|  |--.-----.--.--.-----.--|  |
|   _|   _|  _  |  |  |        |     |  _  |  |  |     |  _  |
|____|__| |___._|_____|__|__|__|__|__|_____|_____|__|__|_____|
    """
    if stdscr:
        for i, line in enumerate(ascii_art.split('\n')):
            stdscr.addstr(i, 0, line)
    else:
        print(ascii_art)

def is_valid_ip(ip):
    pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
    
    if re.match(pattern, ip):
        octets = ip.split('.')
        for octet in octets:
            if int(octet) < 0 or int(octet) > 255:
                return False
        return True
    return False

def get_ip_input():
    while True:
        ip = input("Enter an IP address: ").strip()
        if is_valid_ip(ip):
            return ip
        else:
            print("Invalid IP address. Please try again.")

def display_menu(stdscr, options, selected_idx):
    stdscr.clear()
    h, w = stdscr.getmaxyx()
    display_ascii_art(stdscr)
    stdscr.addstr(6, 0, "TraumHound - Nmap wrapper and reconnaissance tool", curses.A_BOLD)
    stdscr.addstr(8, 0, "Select Nmap Scan Options:")
    for idx, (key, (option, description)) in enumerate(options.items()):
        y = 10 + idx
        if idx == selected_idx:
            stdscr.attron(curses.A_REVERSE)
        checkbox = "[*]" if option in selected_options else "[ ]"
        stdscr.addstr(y, 2, f"{key}. {checkbox} {description}")
        if idx == selected_idx:
            stdscr.attroff(curses.A_REVERSE)
    stdscr.addstr(h-1, 0, "Use arrow keys to navigate, Space to select/deselect, Enter to confirm")
    stdscr.refresh()

def get_scan_options_tui(stdscr):
    global selected_options
    selected_options = []
    option_map = {
        '1': ('sC', "Basic scripts (-sC)"),
        '2': ('sV', "Show version (-sV)"),
        '3': ('O', "OS Version (-O)"),
        '4': ('vuln', "Vulnerability scan (-sV --script vuln)"),
        '5': ('banners', "Banners (--script banner)"),
        '6': ('packet_trace', "Packet Trace (--packet-trace)")
    }
    selected_idx = 0

    while True:
        display_menu(stdscr, option_map, selected_idx)
        key = stdscr.getch()
        if key == ord('\n'):  # Enter key
            break
        elif key == ord(' '):  # Space key
            option = list(option_map.values())[selected_idx][0]
            if option in selected_options:
                selected_options.remove(option)
            else:
                selected_options.append(option)
        elif key == curses.KEY_UP and selected_idx > 0:
            selected_idx -= 1
        elif key == curses.KEY_DOWN and selected_idx < len(option_map) - 1:
            selected_idx += 1

    return selected_options

def get_aggression_level():
    while True:
        level = input('Enter aggression level (1-5, default is 3): ')
        if level == '':
            return 3
        try:
            level = int(level)
            if 1 <= level <= 5:
                return level
            else:
                print("Please enter a number between 1 and 5.")
        except ValueError:
            print("Please enter a valid number.")

def get_port_option():
    print("\nSelect Port Scan Option:")
    print("1. Top 100 ports (-F)")
    print("2. All ports (-p-)")
    print("3. Custom range")
    
    while True:
        choice = input("Enter your choice (1-3): ")
        if choice == '1':
            return "-F"
        elif choice == '2':
            return "-p-"
        elif choice == '3':
            start_port = input('Enter start port: ')
            end_port = input('Enter end port: ')
            return f"-p{start_port}-{end_port}"
        else:
            print("Invalid choice. Please try again.")

def construct_nmap_command(ip, options, aggression, ports):
    timestamp = datetime.now().strftime("%H:%M")
    output_file = f"nmap_scan_{timestamp}.txt"
    
    command = ["nmap", f"-T{aggression}", ports, "-oN", output_file]

    if "sC" in options:
        command.append("-sC")
    if "sV" in options:
        command.append("-sV")
    if "O" in options:
        command.append("-O")
    if "vuln" in options:
        command.extend(["-sV", "--script", "vuln"])
    if "banners" in options:
        command.extend(["--script", "banner"])
    if "packet_trace" in options:
        command.append("--packet-trace")

    command.append(ip)
    return command, output_file

def run_nmap_scan(command, output_file):
    if not is_root():
        sudo_command = ["sudo", "-S"] + command
        print("Running nmap scan with sudo.")
        try:
            sudo_password = prompt("Enter sudo password: ", is_password=True)
            
            process = subprocess.Popen(sudo_command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            def print_output(pipe):
                for line in iter(pipe.readline, ''):
                    print(line, end='')
            
            import threading
            stdout_thread = threading.Thread(target=print_output, args=(process.stdout,))
            stderr_thread = threading.Thread(target=print_output, args=(process.stderr,))
            stdout_thread.start()
            stderr_thread.start()
            
            process.stdin.write(sudo_password + '\n')
            process.stdin.flush()
            
            process.wait()
            stdout_thread.join()
            stderr_thread.join()
            
            if process.returncode != 0:
                print(f"Error: Nmap command failed with return code {process.returncode}")
        except subprocess.CalledProcessError as e:
            print(f"Error running nmap: {e}")
        except FileNotFoundError:
            print("Error: nmap not found. Please ensure nmap is installed and in your PATH.")
    else:
        print("Running nmap scan with root privileges.")
        try:
            process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            def print_output(pipe):
                for line in iter(pipe.readline, ''):
                    print(line, end='')
            
            stdout_thread = threading.Thread(target=print_output, args=(process.stdout,))
            stderr_thread = threading.Thread(target=print_output, args=(process.stderr,))
            stdout_thread.start()
            stderr_thread.start()
            
            process.wait()
            stdout_thread.join()
            stderr_thread.join()
            
            if process.returncode != 0:
                print(f"Error: Nmap command failed with return code {process.returncode}")
        except FileNotFoundError:
            print("Error: nmap not found. Please ensure nmap is installed and in your PATH.")
    
    return output_file

def run_hunter(nmap_output_file, wordlist_path):
    command = f"python3 hunter.py {nmap_output_file} {wordlist_path}"
    try:
        subprocess.run(command, shell=True, check=True)
        print("Hunter completed successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error running Hunter: {e}")

def main():
    display_ascii_art()
    
    ip = get_ip_input()
    
    options = wrapper(get_scan_options_tui)
    aggression = get_aggression_level()
    ports = get_port_option()
    
    command, output_file = construct_nmap_command(ip, options, aggression, ports)
    output_file = run_nmap_scan(command, output_file)
    
    wordlist_path = input("Enter the path to the wordlist for ffuf: ")
    run_hunter(output_file, wordlist_path)

if __name__ == '__main__':
    main()
