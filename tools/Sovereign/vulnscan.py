#!/usr/bin/env python3
import re
import subprocess
from pathlib import Path
from typing import List, Set, Tuple, Dict
import json
import sys

def parse_whatweb_output(whatweb_file: str) -> Tuple[Set[str], Set[str]]:
    """
    Parse whatweb output file and extract service versions and redirects.
    Returns tuple of (services, redirect_locations)
    """
    services = set()
    redirect_locations = set()
    
    try:
        with open(whatweb_file, 'r') as f:
            content = f.read()
            
            # Split content by URLs
            entries = re.split(r'https?://', content)
            
            for entry in entries:
                if not entry.strip():
                    continue
                
                # Look for redirect locations
                redirect_match = re.search(r'RedirectLocation\[(http[^\]]+)\]', entry)
                if redirect_match:
                    redirect_locations.add(redirect_match.group(1))
                
                # Find software versions using various patterns
                
                # Pattern 1: Service[Version]
                service_matches = re.finditer(r'([A-Za-z][A-Za-z0-9_-]+)\[([^\]]+)\]', entry)
                for match in service_matches:
                    service_name = match.group(1)
                    version = match.group(2)
                    
                    # Skip if version doesn't contain any numbers
                    if not any(c.isdigit() for c in version):
                        continue
                    
                    # Extract version number if mixed with other text
                    version_match = re.search(r'([0-9]+(?:\.[0-9]+)+)', version)
                    if version_match:
                        version = version_match.group(1)
                        services.add(f"{service_name.lower()} {version}")
                
                # Pattern 2: Service/Version
                version_matches = re.finditer(r'([A-Za-z][A-Za-z0-9_-]+)/([0-9][0-9a-z._-]+)', entry)
                for match in version_matches:
                    service_name = match.group(1)
                    version = match.group(2)
                    services.add(f"{service_name.lower()} {version}")
                    
                # Pattern 3: Product: Version
                product_matches = re.finditer(r'([A-Za-z][A-Za-z0-9_-]+):\s+([0-9][0-9a-z._-]+)', entry)
                for match in product_matches:
                    service_name = match.group(1)
                    version = match.group(2)
                    services.add(f"{service_name.lower()} {version}")
    
    except FileNotFoundError:
        print(f"[-] Error: Whatweb output file {whatweb_file} not found")
    except Exception as e:
        print(f"[-] Error parsing whatweb output: {e}")
    
    return services, redirect_locations

def parse_nmap_output(nmap_file: str) -> Set[str]:
    """Parse nmap output file and extract service versions"""
    services = set()
    
    try:
        with open(nmap_file, 'r') as f:
            for line in f:
                # Look for version information in service lines
                if 'open' in line and ('tcp' in line or 'udp' in line):
                    # Common version patterns
                    patterns = [
                        r'([A-Za-z][A-Za-z0-9_-]+)[/ ]([0-9][0-9a-z._-]+)',  # service/version
                        r'([A-Za-z][A-Za-z0-9_-]+)\s+([0-9][0-9a-z._-]+)',   # service version
                        r'([A-Za-z][A-Za-z0-9_-]+)_([0-9][0-9a-z._-]+)',     # service_version
                    ]
                    
                    for pattern in patterns:
                        version_match = re.search(pattern, line)
                        if version_match:
                            service = version_match.group(1)
                            version = version_match.group(2)
                            
                            # Skip common false positives
                            if service.lower() not in ['tcp', 'udp', 'port', 'ports']:
                                services.add(f"{service.lower()} {version}")
    
    except FileNotFoundError:
        print(f"[-] Error: Nmap output file {nmap_file} not found")
    except Exception as e:
        print(f"[-] Error parsing nmap output: {e}")
    
    return services

def run_searchsploit_text(service: str, output_file: str) -> bool:
    """Fallback to text-based searchsploit parsing"""
    try:
        process = subprocess.run(
            ["searchsploit", service], 
            capture_output=True, 
            text=True
        )
        
        if process.stdout.strip():
            output_lines = []
            
            service_name = service.split()[0].lower()
            service_version = service.split()[1] if len(service.split()) > 1 else None
            
            for line in process.stdout.splitlines():
                # Remove color codes and clean the line
                line = re.sub(r'\x1b\[[0-9;]*[mK]', '', line)
                line = line.strip()
                
                # Skip separator lines and empty lines
                if not line or all(c in '-|_' for c in line):
                    continue
                
                # Skip path information lines
                if line.startswith('Exploit:') or line.startswith('Path:'):
                    continue
                
                # Check for service name match
                if service_name in line.lower():
                    # If we have a version number, check for version match
                    if service_version:
                        version_parts = service_version.split('.')
                        # Look for major version match at minimum
                        if any(part in line for part in version_parts):
                            output_lines.append(line)
                    else:
                        output_lines.append(line)
            
            # Only write if we have filtered results
            if output_lines:
                with open(output_file, 'a') as f:
                    f.write(f"\n{'='*50}\n")
                    f.write(f"Potential exploits for {service}:\n")
                    f.write(f"{'='*50}\n")
                    f.write('\n'.join(output_lines))
                    f.write("\n\n")
                return True
                
        return False
        
    except Exception as e:
        print(f"[-] Error in text-based searchsploit for {service}: {e}")
        return False

def run_searchsploit(service: str, output_file: str) -> bool:
    """Run searchsploit against a service and append results"""
    try:
        # First try exact version match
        exact_command = ["searchsploit", "--json", f"^{service}$"]
        process = subprocess.run(exact_command, capture_output=True, text=True)
        
        # Then try fuzzy match if exact match fails
        if not process.stdout.strip() or '"RESULTS_EXPLOIT": []' in process.stdout:
            service_name = service.split()[0]  # Get just the service name without version
            process = subprocess.run(["searchsploit", "--json", service_name], 
                                  capture_output=True, text=True)
        
        if process.stdout.strip():
            try:
                results = json.loads(process.stdout)
                if results.get('RESULTS_EXPLOIT'):
                    with open(output_file, 'a') as f:
                        f.write(f"\n{'='*50}\n")
                        f.write(f"Potential exploits for {service}:\n")
                        f.write(f"{'='*50}\n")
                        
                        for exploit in results['RESULTS_EXPLOIT']:
                            # Enhanced filtering for better matches
                            title = exploit.get('Title', '').lower()
                            service_parts = service.lower().split()
                            
                            # Check if both service name and version appear in title
                            if service_parts[0] in title and (
                                len(service_parts) == 1 or 
                                any(v in title for v in service_parts[1].split('.'))
                            ):
                                f.write(f"Title: {exploit['Title']}\n")
                                f.write(f"Path: {exploit['Path']}\n")
                                if exploit.get('Author'):
                                    f.write(f"Author: {exploit['Author']}\n")
                                if exploit.get('Type'):
                                    f.write(f"Type: {exploit['Type']}\n")
                                f.write("\n")
                        
                        return True
            except json.JSONDecodeError:
                # Fallback to text output if JSON fails
                return run_searchsploit_text(service, output_file)
                
        return False
        
    except Exception as e:
        print(f"[-] Error running searchsploit for {service}: {e}")
        return False

def scan_for_vulnerabilities(nmap_file: str, whatweb_file: str, output_dir: Path) -> Tuple[str, Set[str]]:
    """
    Main function to coordinate vulnerability scanning.
    Returns tuple of (vulnerability_report_path, redirect_locations)
    """
    # Create output file for vulnerability report
    timestamp = nmap_file.split('_')[-1].split('.')[0]  # Extract timestamp from nmap filename
    vuln_file = output_dir / f"potential_vulns_{timestamp}.txt"
    
    # Get services from both nmap and whatweb
    nmap_services = parse_nmap_output(nmap_file)
    whatweb_services, redirect_locations = parse_whatweb_output(whatweb_file)
    
    # Combine all unique services
    all_services = nmap_services.union(whatweb_services)
    
    # Create vulnerability report header
    with open(vuln_file, 'w') as f:
        f.write("Vulnerability Scan Report\n")
        f.write(f"Generated: {timestamp}\n\n")
        
        if redirect_locations:
            f.write("Detected Redirects:\n")
            f.write("="*30 + "\n")
            for location in redirect_locations:
                f.write(f"Found redirect to: {location}\n")
            f.write("\n")
        
        f.write("Identified Services:\n")
        f.write("="*30 + "\n")
        for service in sorted(all_services):
            f.write(f"- {service}\n")
        f.write("\n")
    
    # Run searchsploit against each service
    print("[*] Running vulnerability scans...")
    for service in sorted(all_services):
        print(f"[*] Scanning {service}")
        run_searchsploit(service, vuln_file)
    
    # Ensure file is readable if created as root
    vuln_file.chmod(0o644)
    
    return str(vuln_file), redirect_locations

if __name__ == "__main__":
    # Allow for testing the module directly
    if len(sys.argv) < 3:
        print("Usage: vulnscan.py <nmap_file> <whatweb_file>")
        sys.exit(1)
        
    nmap_file = sys.argv[1]
    whatweb_file = sys.argv[2]
    output_dir = Path('scan_results')
    output_dir.mkdir(exist_ok=True)
    
    vuln_file, redirects = scan_for_vulnerabilities(nmap_file, whatweb_file, output_dir)
    print(f"[+] Vulnerability scan completed. Results saved to {vuln_file}")
    if redirects:
        print("\n[+] Detected redirects:")
        for redirect in redirects:
            print(f"    {redirect}")
