#!/usr/bin/env python3

import os
import argparse
import re
import subprocess
import curses
from curses import wrapper
from prompt_toolkit import prompt

# program is intended to run nmap as root, check for sudo privs(if user, False if euid != 0
def is_root():
    return os.geteuid() == 0


# define the ascii-art accompanying the programs console or curses screen
def display_ascii_art(stdscr=None):
    ascii_art = """
.-----.--------.---.-.-----.-----.--.--.
|     |        |  _  |  _  |  _  |  |  |
|__|__|__|__|__|___._|   __|   __|___  |
 author - griefhound |__|  |__|  |_____|
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



def read_ip_list(file_path):
    valid_ips = []
    invalid_ips = []
    
    try:
        with open(file_path, 'r') as file:
            for line in file:
                ip = line.strip()
                if is_valid_ip(ip):
                    valid_ips.append(ip)
                else:
                    invalid_ips.append(ip)
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
    except PermissionError:
        print(f"Error: Permission denied when trying to read '{file_path}'.")
    
    return valid_ips, invalid_ips



def display_ip_lists(valid_ips, invalid_ips):
    print("Valid IP addresses:")
    for ip in valid_ips:
        print(f"  {ip}")
    
    if invalid_ips:
        print("\nInvalid IP addresses found:")
        for ip in invalid_ips:
            print(f"  {ip}")

            

def display_menu(stdscr, options, selected_idx):
    stdscr.clear()
    h, w = stdscr.getmaxyx()
    display_ascii_art(stdscr)
    stdscr.addstr(6, 0, "PyNmap - Python wrapper for Nmap", curses.A_BOLD)
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



# prompt user for port selection
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



# Construct the command based on selection
def construct_nmap_command(ips, options, aggression, ports, output_file=None):
    command = ["nmap", f"-T{aggression}", ports]

    if output_file:
        command.extend(["-oN", output_file])

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

# Add ip-addresses to command
    command.extend(ips)
    return command



# Run the constructed comand
def run_nmap_scan(command):
    if not is_root():
        sudo_command = ["sudo", "-S"] + command
        print("Running nmap scan with sudo.")
        try:
            # Prompt for sudo password
            sudo_password = prompt("Enter sudo password: ", is_password=True)
            
            # Run the command with sudo
            process = subprocess.Popen(sudo_command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            # Use communicate to send the password and get real-time output
            def print_output(pipe):
                for line in iter(pipe.readline, ''):
                    print(line, end='')
            
            # Start threads to print output in real-time
            import threading
            stdout_thread = threading.Thread(target=print_output, args=(process.stdout,))
            stderr_thread = threading.Thread(target=print_output, args=(process.stderr,))
            stdout_thread.start()
            stderr_thread.start()
            
            # Send the password
            process.stdin.write(sudo_password + '\n')
            process.stdin.flush()
            
            # Wait for the process to complete
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
            
            # Use the same print_output function for real-time output
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



def run_tui(stdscr, file_path):
    curses.curs_set(0)  # Hide the cursor
    
    # Initial screen
    stdscr.clear()
    display_ascii_art(stdscr)
    stdscr.addstr(6, 0, "Press any key to continue...")
    stdscr.refresh()
    stdscr.getch()

    # Read IP addresses
    valid_ips, invalid_ips = read_ip_list(file_path)
    
    # Display IP lists
    stdscr.clear()
    display_ascii_art(stdscr)
    stdscr.addstr(6, 0, f"Reading IP addresses from: {file_path}")
    stdscr.addstr(8, 0, "Valid IP addresses:")
    for idx, ip in enumerate(valid_ips):
        stdscr.addstr(9 + idx, 2, ip)
    if invalid_ips:
        stdscr.addstr(10 + len(valid_ips), 0, "Invalid IP addresses found:")
        for idx, ip in enumerate(invalid_ips):
            stdscr.addstr(11 + len(valid_ips) + idx, 2, ip)
    stdscr.addstr(12 + len(valid_ips) + len(invalid_ips), 0, "Press any key to continue...")
    stdscr.refresh()
    stdscr.getch()

    if not valid_ips:
        stdscr.addstr(14 + len(valid_ips) + len(invalid_ips), 0, "No valid IP addresses found. Exiting.")
        stdscr.refresh()
        stdscr.getch()
        return

    # Get scan options
    options = get_scan_options_tui(stdscr)

    # Get aggression level
    stdscr.clear()
    display_ascii_art(stdscr)
    stdscr.addstr(6, 0, "Enter aggression level (1-5, default is 3): ")
    stdscr.refresh()
    curses.echo()
    aggression_level = stdscr.getstr().decode('utf-8')
    curses.noecho()
    aggression_level = int(aggression_level) if aggression_level else 3

    # Get port option
    stdscr.clear()
    display_ascii_art(stdscr)
    stdscr.addstr(6, 0, "Select Port Scan Option:")
    stdscr.addstr(8, 0, "1. Top 100 ports (-F)")
    stdscr.addstr(9, 0, "2. All ports (-p-)")
    stdscr.addstr(10, 0, "3. Custom range")
    stdscr.refresh()
    while True:
        choice = stdscr.getch()
        if choice == ord('1'):
            port_option = "-F"
            break
        elif choice == ord('2'):
            port_option = "-p-"
            break
        elif choice == ord('3'):
            stdscr.addstr(12, 0, "Enter start port: ")
            stdscr.refresh()
            curses.echo()
            start_port = stdscr.getstr().decode('utf-8')
            stdscr.addstr(13, 0, "Enter end port: ")
            stdscr.refresh()
            end_port = stdscr.getstr().decode('utf-8')
            curses.noecho()
            port_option = f"-p{start_port}-{end_port}"
            break

    # Ask about saving output
    stdscr.clear()
    display_ascii_art(stdscr)
    stdscr.addstr(6, 0, "Do you want to save the output to a file? (y/n): ")
    stdscr.refresh()
    save_output = stdscr.getch() == ord('y')
    output_file = None
    if save_output:
        stdscr.addstr(8, 0, "Enter the filename to save the output: ")
        stdscr.refresh()
        curses.echo()
        output_file = stdscr.getstr().decode('utf-8').strip()
        curses.noecho()

    # Construct and display nmap command
    nmap_command = construct_nmap_command(valid_ips, options, aggression_level, port_option, output_file)
    stdscr.clear()
    display_ascii_art(stdscr)
    stdscr.addstr(6, 0, "Constructed nmap command:")
    stdscr.addstr(8, 0, " ".join(nmap_command))
    stdscr.addstr(10, 0, "Press any key to start the scan...")
    stdscr.refresh()
    stdscr.getch()

    # Run nmap scan
    stdscr.clear()
    display_ascii_art(stdscr)
    stdscr.addstr(6, 0, "Running nmap scan...")
    stdscr.refresh()
    curses.endwin()  # Temporarily end curses mode
    run_nmap_scan(nmap_command)
    stdscr = curses.initscr()  # Reinitialize curses
    
    '''
    # Final message
    stdscr.clear()
    display_ascii_art(stdscr)
    stdscr.addstr(6, 0, "Scan completed.")
    if save_output:
        stdscr.addstr(8, 0, f"Scan results have been saved to {output_file}")
    stdscr.addstr(10, 0, "Press any key to exit...")
    stdscr.refresh()
    stdscr.getch()
    '''

def main():
    parser = argparse.ArgumentParser(description='nmappy- Python wrapper for Nmap')
    parser.add_argument('file_path', nargs='?', help='Path to the IP list file')
    args = parser.parse_args()

    if args.file_path:
        file_path = args.file_path
    else:
        display_ascii_art()
        file_path = prompt('Enter the path to the IP list file: ')

    wrapper(run_tui, file_path)

if __name__ == '__main__':
    main()
