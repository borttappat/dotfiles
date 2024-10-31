#!/usr/bin/env python3
import re
import subprocess
from pathlib import Path
from typing import List, Set, Tuple, Dict

def clean_service_string(service: str) -> str:
    """
    Clean service strings by removing brackets and extra info
    Example: 'Apache[2.4.52]' -> 'apache 2.4.52'
    """
    # Skip if service string is too short
    if len(service) < 3:
        return ""
        
    # Remove ANSI color codes
    service = re.sub(r'\x1b\[[0-9;]*[mK]', '', service)
    
    # List of terms to ignore (too generic)
    ignore_terms = {
        'ip', 'tcp', 'udp', 'the', 'and', 'for', 'web', 'api',
        'com', 'org', 'net', 'www', 'http', 'https', 'ftp'
    }
    
    # Remove common Linux/Ubuntu references
    service = re.sub(r'\(Ubuntu\)', '', service)
    service = re.sub(r'\(Debian\)', '', service)
    service = re.sub(r'\(Linux\)', '', service)
    
    # Extract service name and version from brackets/parentheses
    match = re.search(r'([a-zA-Z0-9_-]+)[\[\(]([0-9][0-9a-z._-]+)[\]\)]', service)
    if match:
        service_name = match.group(1).lower()
        version = match.group(2)
        
        # Skip if service name is in ignore list
        if service_name in ignore_terms:
            return ""
            
        # Skip if version doesn't start with a number
        if not version[0].isdigit():
            return ""
            
        return f"{service_name} {version}"
    
    # Try to match service names with versions without brackets
    match = re.search(r'([a-zA-Z0-9_-]+)[\/\s]([0-9][0-9a-z._-]+)', service)
    if match:
        service_name = match.group(1).lower()
        version = match.group(2)
        
        # Skip if service name is in ignore list
        if service_name in ignore_terms:
            return ""
            
        # Skip if version doesn't start with a number
        if not version[0].isdigit():
            return ""
            
        return f"{service_name} {version}"
    
    return ""

def parse_whatweb_output(whatweb_file: str) -> Tuple[Set[str], Set[str]]:
    """
    Parse whatweb output file and extract service versions and redirects.
    Returns (services, redirect_locations)
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
                
                # Find all service[version] patterns
                service_matches = re.finditer(r'([a-zA-Z0-9-]+)\[([^\]]+)\]', entry)
                for match in service_matches:
                    service = f"{match.group(1)}[{match.group(2)}]"
                    cleaned = clean_service_string(service)
                    if cleaned:
                        services.add(cleaned)
    
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
                # Look for port lines with version information
                if 'open' in line and ('tcp' in line or 'udp' in line):
                    parts = line.split()
                    if len(parts) >= 5:
                        service = ' '.join(parts[3:])  # Join all parts after service name
                        cleaned = clean_service_string(service)
                        if cleaned:
                            services.add(cleaned)
    
    except FileNotFoundError:
        print(f"[-] Error: Nmap output file {nmap_file} not found")
    except Exception as e:
        print(f"[-] Error parsing nmap output: {e}")
    
    return services

def run_searchsploit(service: str, output_file: str) -> bool:
    """
    Run searchsploit against a service and append results to output file
    Returns True if any valid results were found and written
    """
    try:
        command = ["searchsploit", service]
        process = subprocess.run(
            command,
            capture_output=True,
            text=True
        )
        
        if process.stdout.strip():
            # Clean and filter the output
            output_lines = []
            
            # Extract service name for exact matching
            service_name = service.split()[0].lower()
            
            for line in process.stdout.splitlines():
                # Remove ANSI color codes
                line = re.sub(r'\x1b\[[0-9;]*[mK]', '', line)
                
                # Skip separator lines and empty lines
                if not line.strip() or all(c in '-|_' for c in line.strip()):
                    continue
                    
                # Check for exact service name match
                if re.search(rf'\b{re.escape(service_name)}\b', line.lower()):
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
        print(f"[-] Error running searchsploit for {service}: {e}")
        return False

def scan_for_vulnerabilities(nmap_file: str, whatweb_file: str, output_dir: Path) -> Tuple[str, Set[str]]:
    """
    Main function to coordinate vulnerability scanning
    Returns (vulnerability_report_path, redirect_locations)
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
    
    # Run searchsploit against each service
    print("[*] Running vulnerability scans...")
    for service in all_services:
        print(f"[*] Scanning {service}")
        run_searchsploit(service, vuln_file)
    
    # Ensure file is readable if created as root
    vuln_file.chmod(0o644)
    
    return str(vuln_file), redirect_locations

if __name__ == "__main__":
    # Allow for testing the module directly
    import sys
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
