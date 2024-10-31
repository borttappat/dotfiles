#!/usr/bin/env python3
import argparse
import subprocess
import re
import os
import sys
from pathlib import Path
from datetime import datetime
import paramiko
from prompt_toolkit import prompt
from prompt_toolkit.completion import WordCompleter
from vulnscan import scan_for_vulnerabilities, parse_whatweb_output

def check_privileges():
    """Check if script is running with sudo/root privileges"""
    return os.geteuid() == 0

def run_nmap_scan(target, output_file):
    """Run nmap scan with appropriate privileges"""
    try:
        # Base command with basic options
        if check_privileges():
            command = [
                "nmap",
                "-sV",     # Service version detection (needs root)
                "-p-",     # All ports (needs root for SYN scan)
                "-T4",     # Aggressive timing
                "--script=http-title,http-headers,http-methods,http-enum",  # Basic HTTP enumeration
                "-oN",     # Normal output format
                output_file,
                target
            ]
            print("[+] Running privileged scan (all ports, version detection)")
        else:
            command = [
                "nmap",
                "-sT",     # TCP connect scan (doesn't need root)
                "-p 80,443,8080,8443",  # Common web ports only
                "-T4",     # Aggressive timing
                "--script=http-title,http-headers",  # Limited HTTP scripts
                "-oN",     # Normal output format
                output_file,
                target
            ]
            print("[!] Running unprivileged scan (limited ports, no version detection)")
            print("[!] Run with sudo for full scan capabilities")

        print(f"[*] Starting scan against {target}")
        process = subprocess.run(command, capture_output=True, text=True)

        if process.returncode == 0:
            print(f"[+] Scan completed. Results saved to {output_file}")
            return True
        else:
            print(f"[-] Nmap scan failed: {process.stderr}")
            return False

    except Exception as e:
        print(f"[-] Error running nmap: {e}")
        return False

def identify_web_services(nmap_output):
    """Parse nmap output to identify web services"""
    web_ports = []
    web_services = ["http", "https", "http-alt", "http-proxy", "www", "wordpress"]

    try:
        with open(nmap_output, "r") as f:
            for line in f:
                if any(service in line.lower() for service in web_services):
                    if "open" in line and "tcp" in line:
                        port = line.split("/")[0].strip()
                        web_ports.append(port)
        return web_ports
    except Exception as e:
        print(f"[-] Error parsing nmap output: {e}")
        return []

def ensure_directory_permissions(directory):
    """Ensure the directory exists and has correct permissions"""
    try:
        directory.mkdir(exist_ok=True)
        directory.chmod(0o755)
        return True
    except Exception as e:
        print(f"[-] Error setting up directory {directory}: {e}")
        return False

def run_whatweb(target, ports, output_file):
    """Run whatweb against discovered web services"""
    try:
        with open(output_file, "w") as f:
            for port in ports:
                for protocol in ['http', 'https']:
                    target_url = f"{protocol}://{target}:{port}"
                    command = ["whatweb", "--color=always", target_url]

                    print(f"[*] Running whatweb against {target_url}")

                    process = subprocess.run(command, capture_output=True, text=True)

                    if process.stdout:
                        f.write(process.stdout)

        os.chmod(output_file, 0o644)
        return True

    except Exception as e:
        print(f"[-] Error running whatweb: {e}")
        return False

def update_hosts_file(target_ip, hostnames, is_nixos=False):
    """Update system hosts file with discovered hostnames"""
    try:
        if is_nixos:
            hosts_file = Path.home() / "dotfiles/modules/hosts.nix"
            if not hosts_file.exists():
                print("[-] NixOS hosts file not found at expected location")
                return False
                
            # Read existing content
            content = hosts_file.read_text()
            
            # Find the extraHosts section
            hosts_section = re.search(r'networking.extraHosts\s*=\s*\'\'([^\']*)', content)
            if not hosts_section:
                print("[-] Could not find extraHosts section in hosts.nix")
                return False
                
            # Add new entries
            new_entries = []
            for hostname in hostnames:
                entry = f"{target_ip} {hostname}"
                if entry not in content:
                    new_entries.append(entry)
            
            if new_entries:
                # Add entries to the hosts section
                updated_content = content.replace(
                    hosts_section.group(0),
                    f"{hosts_section.group(0)}\n    " + "\n    ".join(new_entries)
                )
                
                # Write updated content directly (no backup needed since it's git tracked)
                hosts_file.write_text(updated_content)
                
                print("[+] Updated NixOS hosts file. Run rebuild to apply changes.")
                return True
            
        else:
            hosts_file = Path("/etc/hosts")
            if not hosts_file.exists():
                print("[-] System hosts file not found")
                return False
                
            # Read existing entries
            content = hosts_file.read_text()
            
            # Add new entries
            new_entries = []
            for hostname in hostnames:
                entry = f"{target_ip} {hostname}"
                if entry not in content:
                    new_entries.append(entry)
            
            if new_entries:
                with open(hosts_file, 'a') as f:
                    f.write("\n# Added by scanner.py\n")
                    for entry in new_entries:
                        f.write(f"{entry}\n")
                
                print("[+] Updated system hosts file")
                return True
                
        return False
            
    except Exception as e:
        print(f"[-] Error updating hosts file: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="Web service enumeration tool")
    parser.add_argument("target", help="Target IP address or hostname")
    parser.add_argument("--nixos", action="store_true", help="Target system is NixOS")
    parser.add_argument("--no-hosts", action="store_true", help="Skip hosts file updates")
    args = parser.parse_args()

    # Create output directory with proper permissions
    output_dir = Path("scan_results")
    if not ensure_directory_permissions(output_dir):
        sys.exit(1)

    # Generate output filenames
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    nmap_output = output_dir / f"nmap_scan_{timestamp}.txt"
    
    # Run initial nmap scan
    if run_nmap_scan(args.target, str(nmap_output)):
        web_ports = identify_web_services(nmap_output)
        
        if web_ports:
            print(f"[+] Discovered web services on ports: {', '.join(web_ports)}")
            
            # Run whatweb against discovered services
            whatweb_output = output_dir / f"whatweb_scan_{timestamp}.txt"
            if run_whatweb(args.target, web_ports, whatweb_output):
                print(f"[+] Whatweb scan completed. Results saved to {whatweb_output}")
                
                # Run vulnerability scan
                vuln_file, redirect_locations = scan_for_vulnerabilities(
                    str(nmap_output),
                    str(whatweb_output),
                    output_dir
                )
                
                print(f"[+] Vulnerability scan completed. Results saved to {vuln_file}")
                
                # Handle discovered hostnames
                if redirect_locations and not args.no_hosts:
                    hostnames = set()
                    for location in redirect_locations:
                        hostname = location.split('://')[-1].split('/')[0]
                        hostnames.add(hostname)
                    
                    if hostnames:
                        print("\n[+] Discovered hostnames:")
                        for hostname in hostnames:
                            print(f"    {hostname}")
                        
                        if prompt("Update hosts file? [y/N] ").lower() == 'y':
                            update_hosts_file(args.target, hostnames, args.nixos)
        else:
            print("[-] No web services discovered")

if __name__ == "__main__":
    main()
