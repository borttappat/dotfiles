#!/usr/bin/env python3
import argparse
import subprocess
import re
import os
import sys
from pathlib import Path
from datetime import datetime
import nmap
from vulnscan import scan_for_vulnerabilities

def check_privileges():
    """Check if script is running with sudo/root privileges"""
    return os.geteuid() == 0

def run_nmap_scan(target, output_file):
    """Run nmap scan using python-nmap library"""
    try:
        # Initialize nmap scanner
        scanner = nmap.PortScanner()
        
        if check_privileges():
            print("[+] Running privileged scan (all ports, version detection)")
            # Run comprehensive scan
            scanner.scan(
                target,
                arguments='-sV -p- -T4 --script=http-title,http-headers,http-methods,http-enum'
            )
        else:
            print("[!] Running unprivileged scan (limited ports, no version detection)")
            print("[!] Run with sudo for full scan capabilities")
            # Run limited scan
            scanner.scan(
                target,
                arguments='-sT -p 80,443,8080,8443 -T4 --script=http-title,http-headers'
            )

        print(f"[*] Starting nmap scan against {target}")
        
        # Save scan results to file
        with open(output_file, 'w') as f:
            # Write scan information
            f.write(f"Nmap scan report for {target}\n")
            
            if target in scanner.all_hosts():
                host = scanner[target]
                
                # Write host information
                if 'status' in host:
                    f.write(f"Host is {host['status']['state']}\n")
                
                # Write port information
                if 'tcp' in host:
                    for port in host['tcp']:
                        port_info = host['tcp'][port]
                        f.write(f"\n{port}/tcp {port_info['state']} {port_info['name']}")
                        if 'product' in port_info:
                            f.write(f" {port_info['product']}")
                        if 'version' in port_info:
                            f.write(f" {port_info['version']}")
                        f.write('\n')
                        
                        # Write script output if available
                        if 'script' in port_info:
                            for script_name, output in port_info['script'].items():
                                f.write(f"{script_name}:\n{output}\n")
            
            print(f"[+] Nmap scan completed. Results saved to {output_file}")
            return True

    except nmap.PortScannerError as e:
        print(f"[-] Nmap scan error: {e}")
        return False
    except Exception as e:
        print(f"[-] Error running nmap: {e}")
        return False

def summarize_findings(nmap_file, whatweb_file, ffuf_file, vuln_file):
    """Create a summary of all findings"""
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        summary_file = Path("scan_results") / f"scan_summary_{timestamp}.txt"
        
        with open(summary_file, 'w') as f:
            f.write("Web Service Scan Summary\n")
            f.write("=" * 50 + "\n\n")
            
            # Nmap findings
            f.write("Open Ports and Services:\n")
            f.write("-" * 30 + "\n")
            with open(nmap_file, 'r') as nmap:
                for line in nmap:
                    if 'tcp' in line and 'open' in line:
                        f.write(line)
            f.write("\n")
            
            # Directories from nmap http-enum
            enum_dirs = parse_nmap_directories(nmap_file)
            if enum_dirs:
                f.write("Directories Found by Nmap:\n")
                f.write("-" * 30 + "\n")
                for dir in enum_dirs:
                    f.write(f"{dir}\n")
                f.write("\n")
            
            # WhatWeb findings
            f.write("Web Technologies:\n")
            f.write("-" * 30 + "\n")
            with open(whatweb_file, 'r') as ww:
                f.write(ww.read())
            f.write("\n")
            
            # FFUF findings
            if ffuf_file and os.path.exists(ffuf_file):
                f.write("Directory Enumeration Results:\n")
                f.write("-" * 30 + "\n")
                with open(ffuf_file, 'r') as ff:
                    f.write(ff.read())
                f.write("\n")
            
            # Vulnerability findings
            if vuln_file and os.path.exists(vuln_file):
                f.write("Potential Vulnerabilities:\n")
                f.write("-" * 30 + "\n")
                with open(vuln_file, 'r') as vf:
                    f.write(vf.read())
            
        print(f"[+] Scan summary saved to {summary_file}")
        return str(summary_file)
        
    except Exception as e:
        print(f"[-] Error creating summary: {e}")
        return None

def identify_web_services(nmap_output):
    """Parse nmap output file to identify web services"""
    web_ports = []
    web_services = ["http", "https", "http-alt", "http-proxy", "www", "wordpress"]

    try:
        with open(nmap_output, "r") as f:
            for line in f:
                if any(service in line.lower() for service in web_services):
                    if "tcp" in line and not line.startswith('#'):
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

def run_ffuf(target, ports, wordlist_path, output_dir):
    """Run ffuf directory enumeration with improved output handling"""
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        json_output = output_dir / f"ffuf_scan_{timestamp}.json"
        readable_output = output_dir / f"ffuf_directories_{timestamp}.txt"
        
        for port in ports:
            for protocol in ['http', 'https']:
                target_url = f"{protocol}://{target}:{port}/FUZZ"
                command = [
                    "ffuf",
                    "-w", wordlist_path,
                    "-u", target_url,
                    "-o", str(json_output),
                    "-s",                       # Silent mode
                    "-mc", "200,204,301,302,307,401,403",  # Status codes to display
                    "-of", "json"               # JSON output format
                ]
                
                print(f"[*] Running ffuf against {target_url}")
                process = subprocess.run(command, capture_output=True, text=True)
                
                # Process JSON output and create readable version
                if os.path.exists(json_output):
                    try:
                        with open(json_output, 'r') as f:
                            results = json.load(f)
                            
                            with open(readable_output, 'a') as out:
                                out.write(f"\nDirectory Scan Results for {target_url}\n")
                                out.write("="*50 + "\n")
                                
                                if results.get('results'):
                                    for result in results['results']:
                                        status = result.get('status', 'N/A')
                                        length = result.get('length', 'N/A')
                                        url = result.get('url', '').replace('FUZZ', result.get('input', ''))
                                        
                                        out.write(f"Status: {status} | Size: {length} | URL: {url}\n")
                                else:
                                    out.write("No directories found\n")
                                
                                out.write("\n")
                    except json.JSONDecodeError:
                        print(f"[-] Error parsing ffuf JSON output")
                
                if os.path.exists(readable_output) and os.path.getsize(readable_output) > 0:
                    print(f"[+] Found directories at {target_url}")
        
        # Return both filenames
        return str(readable_output)
    except Exception as e:
        print(f"[-] Error running ffuf: {e}")
        return None

def parse_nmap_directories(nmap_output):
    """Extract directories found by nmap's http-enum script"""
    directories = []
    try:
        with open(nmap_output, 'r') as f:
            content = f.read()
            
            # Find the http-enum section
            enum_section = re.search(r'http-enum:(.*?)(?:\n\n|\Z)', content, re.DOTALL)
            if enum_section:
                # Extract directories
                for line in enum_section.group(1).splitlines():
                    if ':' in line:
                        directory = line.split(':')[0].strip()
                        if directory.startswith('/'):
                            directories.append(directory)
        
        return directories
    except Exception as e:
        print(f"[-] Error parsing nmap directories: {e}")
        return []

def run_subdomain_enum(target, wordlist_path, output_dir):
    """Run ffuf for subdomain enumeration"""
    try:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_file = output_dir / f"subdomains_{timestamp}.txt"
        
        for protocol in ['http', 'https']:
            target_url = f"{protocol}://FUZZ.{target}"
            command = [
                "ffuf",
                "-w", wordlist_path,
                "-u", target_url,
                "-o", str(output_file),
                "-s",
                "-mc", "200,204,301,302,307",
                "-fs", "0"
            ]
            
            print(f"[*] Enumerating subdomains for {target} ({protocol})")
            process = subprocess.run(command, capture_output=True, text=True)
            
            if process.returncode == 0 and os.path.getsize(output_file) > 0:
                print(f"[+] Found subdomains for {target}")
        
        return str(output_file)
    except Exception as e:
        print(f"[-] Error during subdomain enumeration: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Web service enumeration tool")
    parser.add_argument("target", help="Target IP address or hostname")
    parser.add_argument("--dir-wordlist", help="Wordlist for directory enumeration")
    parser.add_argument("--sub-wordlist", help="Wordlist for subdomain enumeration")
    args = parser.parse_args()

    # Create output directory
    output_dir = Path("scan_results")
    if not ensure_directory_permissions(output_dir):
        sys.exit(1)

    # Generate output filenames
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    nmap_output = output_dir / f"nmap_scan_{timestamp}.txt"

    # Store all scan files for summary
    scan_files = {
        'nmap': str(nmap_output),
        'whatweb': None,
        'ffuf': None,
        'vuln': None
    }

    # Run initial nmap scan
    if run_nmap_scan(args.target, str(nmap_output)):
        web_ports = identify_web_services(nmap_output)

        if web_ports:
            print(f"\n[+] Discovered web services on ports: {', '.join(web_ports)}")

            # Run whatweb against discovered services
            whatweb_output = output_dir / f"whatweb_scan_{timestamp}.txt"
            if run_whatweb(args.target, web_ports, whatweb_output):
                print(f"[+] Whatweb scan completed. Results saved to {whatweb_output}")
                scan_files['whatweb'] = str(whatweb_output)

                # Optional directory enumeration
                if args.dir_wordlist:
                    if os.path.exists(args.dir_wordlist):
                        ffuf_output = run_ffuf(args.target, web_ports, args.dir_wordlist, output_dir)
                        if ffuf_output:
                            print(f"[+] Directory enumeration completed. Results saved to {ffuf_output}")
                            scan_files['ffuf'] = ffuf_output
                    else:
                        print(f"[-] Directory wordlist not found: {args.dir_wordlist}")

                # Run vulnerability scan
                vuln_file, redirect_locations = scan_for_vulnerabilities(
                    str(nmap_output),
                    str(whatweb_output),
                    output_dir
                )
                scan_files['vuln'] = vuln_file

                print(f"\n[+] Vulnerability scan completed. Results saved to {vuln_file}")

                if redirect_locations:
                    print("\n[+] Discovered redirects:")
                    for location in redirect_locations:
                        print(f"    {location}")

                # Create final summary
                summary_file = summarize_findings(
                    scan_files['nmap'],
                    scan_files['whatweb'],
                    scan_files['ffuf'],
                    scan_files['vuln']
                )
                if summary_file:
                    print(f"\n[+] Complete scan summary saved to {summary_file}")
        else:
            print("[-] No web services discovered")

if __name__ == "__main__":
    main()
