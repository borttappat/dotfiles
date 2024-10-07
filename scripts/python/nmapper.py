import os
import nmap
from datetime import datetime

ascii_art = """
.-----.--------.---.-.-----.-----.-----.----.
|     |        |  _  |  _  |  _  |  -__|   _|
|__|__|__|__|__|___._|   __|   __|_____|__|
                     |__|  |__|
    """
print(ascii_art)

def ip_choice():
    while True:
        ip_method = input("\nDo you want to:\n1) Enter an IP directly or\n2) Use a list?\nChoice(1/2): ")
        if ip_method in ['1', '2']:
            return int(ip_method)
        else:
            print("Invalid input, please enter 1 or 2")

def get_ip():
    choice = ip_choice()
    if choice == 1:
        return [input("What IP address do you want to scan? ")]
    elif choice == 2:
        file_path = input("Enter the path to the file containing your target IP addresses: ")
        with open(file_path, 'r') as file:
            return [line.strip() for line in file]

def get_scan_flags():
    flag_options = {
        1: "-sV",
        2: "-sC",
        3: "-O",
        4: "--script vuln"
    }
    
    print("\nSelect scan flags (you can choose multiple):")
    for key, value in flag_options.items():
        print(f"{key}) {value}")
    
    while True:
        choices = input("\nEnter the numbers of the flags you want to use, separated by spaces (e.g., 1 3 4): ").split()
        
        try:
            selected_numbers = [int(choice) for choice in choices]
            if all(1 <= num <= 4 for num in selected_numbers):
                return [flag_options[num] for num in selected_numbers]
            else:
                print("Invalid input. Please enter numbers between 1 and 4.")
        except ValueError:
            print("Invalid input. Please enter numbers only.")

def get_port_option():
    port_options = {
        1: "-p-",
        2: "-p",
        3: "-F"
    }
    
    print("\nSelect port scanning option:")
    print("1) Scan all ports (-p-)")
    print("2) Scan specific port range (-p)")
    print("3) Scan top 100 ports (-F)")
    
    while True:
        choice = input("Enter the number of your choice (1-3): ")
        if choice in ['1', '3']:
            return port_options[int(choice)]
        elif choice == '2':
            port_range = input("Enter the port range (e.g., 1-1000, 80,443,8080): ")
            return f"-p {port_range}"
        else:
            print("Invalid input. Please enter a number between 1 and 3.")

def get_scan_aggression():
    print("\nSelect scan aggression level (1-5):")
    print("1: Slowest (most stealthy)")
    print("2: Sneaky")
    print("3: Normal")
    print("4: Aggressive")
    print("5: Fastest (may overwhelm targets)")
    
    while True:
        choice = input("Enter your choice (1-5): ")
        if choice in ['1', '2', '3', '4', '5']:
            return f"-T{choice}"
        else:
            print("Invalid input. Please enter a number between 1 and 5.")

def save_to_file(scan_results):
    save_option = input("Do you want to save the scan results to a file? (y/n): ")
    if save_option.lower() == 'y':
        timestamp = datetime.now().strftime("%H:%M")
        filename = f"scan_results_{timestamp}.txt"
        with open(filename, 'w') as f:
            for host in scan_results:
                f.write(f"Host: {host}\n")
                for proto in scan_results[host].all_protocols():
                    f.write(f"Protocol: {proto}\n")
                    ports = scan_results[host][proto].keys()
                    for port in ports:
                        service = scan_results[host][proto][port]
                        f.write(f"  Port: {port}\n")
                        f.write(f"    State: {service['state']}\n")
                        if 'name' in service:
                            f.write(f"    Service: {service['name']}\n")
                        if 'version' in service:
                            f.write(f"    Version: {service['version']}\n")
                f.write("\n")
        print(f"Scan results saved to {filename}")

def main():
    ip_addresses = get_ip()
    print("IP addresses to scan:", ip_addresses)

    scan_flags = get_scan_flags()
    print("Selected scan flags:", " ".join(scan_flags))

    port_option = get_port_option()
    print("Selected port option:", port_option)

    aggression = get_scan_aggression()
    print("Selected aggression level:", aggression)

    nm = nmap.PortScanner()
    
    ip_string = " ".join(ip_addresses)
    arguments = f"{' '.join(scan_flags)} {port_option} {aggression}"
    
    print("\nFinal nmap command:")
    print(f"nmap {arguments} {ip_string}")
    
    print("\nStarting nmap scan...")
    
    try:
        nm.scan(hosts=ip_string, arguments=arguments)
        
        scan_results = {}
        for host in nm.all_hosts():
            scan_results[host] = nm[host]
        
        print("\nScan completed. Results:")
        for host in scan_results:
            print(f"Host: {host}")
            for proto in scan_results[host].all_protocols():
                print(f"Protocol: {proto}")
                ports = scan_results[host][proto].keys()
                for port in ports:
                    service = scan_results[host][proto][port]
                    print(f"  Port: {port}")
                    print(f"    State: {service['state']}")
                    if 'name' in service:
                        print(f"    Service: {service['name']}")
                    if 'version' in service:
                        print(f"    Version: {service['version']}")
        
        save_to_file(scan_results)
        
    except nmap.PortScannerError as e:
        print(f"Nmap scan error: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
