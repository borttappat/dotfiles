#!/usr/bin/env python3
import re
import subprocess
from pathlib import Path
from typing import List, Set, Tuple


def clean_service_string(service: str) -> str:
    """
    Clean service strings by removing brackets, parentheses, and extra info
    Example: 'Apache[2.4.52]' -> 'apache 2.4.52'
    """
    # Remove common Linux/Ubuntu references that might affect searchsploit results
    service = re.sub(r"\(Ubuntu\)", "", service)
    service = re.sub(r"\(Debian\)", "", service)
    service = re.sub(r"Linux", "", service)

    # Extract service name and version from brackets
    match = re.search(r"([a-zA-Z0-9-]+)[\[\(]([0-9.p-]+)[\]\)]", service)
    if match:
        return f"{match.group(1).lower()} {match.group(2)}"

    return ""


def parse_whatweb_output(whatweb_file: str) -> Set[str]:
    """
    Parse whatweb output file and extract service versions.
    Also looks for RedirectLocation entries.
    """
    services = set()
    redirect_locations = set()

    try:
        with open(whatweb_file, "r") as f:
            content = f.read()

            # Split content by URLs (each scan entry starts with http:// or https://)
            entries = re.split(r"https?://", content)

            for entry in entries:
                if not entry.strip():
                    continue

                # Look for redirect locations
                redirect_match = re.search(r"RedirectLocation\[(http[^\]]+)\]", entry)
                if redirect_match:
                    redirect_locations.add(redirect_match.group(1))

                # Find all service[version] patterns
                service_matches = re.finditer(r"([a-zA-Z0-9-]+)\[([^\]]+)\]", entry)
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
    """
    Parse nmap output file and extract service versions
    """
    services = set()

    try:
        with open(nmap_file, "r") as f:
            for line in f:
                # Look for port lines with version information
                if "open" in line and ("tcp" in line or "udp" in line):
                    # Try to extract service and version
                    # Example: "80/tcp   open  http    Apache httpd 2.4.52 ((Ubuntu))"
                    parts = line.split()
                    if len(parts) >= 5:
                        service = " ".join(
                            parts[3:]
                        )  # Join all parts after the service name
                        cleaned = clean_service_string(service)
                        if cleaned:
                            services.add(cleaned)

    except FileNotFoundError:
        print(f"[-] Error: Nmap output file {nmap_file} not found")
    except Exception as e:
        print(f"[-] Error parsing nmap output: {e}")

    return services


def run_searchsploit(service: str, output_file: str):
    """
    Run searchsploit against a service and append results to output file
    """
    try:
        command = ["searchsploit", service]
        process = subprocess.run(command, capture_output=True, text=True)

        if process.stdout.strip():  # Only write if we got results
            with open(output_file, "a") as f:
                f.write(f"\n{'='*50}\n")
                f.write(f"Potential exploits for {service}:\n")
                f.write(f"{'='*50}\n")
                f.write(process.stdout)
                f.write("\n")

            return True
    except Exception as e:
        print(f"[-] Error running searchsploit for {service}: {e}")
        return False


def scan_for_vulnerabilities(
    nmap_file: str, whatweb_file: str, output_dir: Path
) -> Tuple[str, Set[str]]:
    """
    Main function to coordinate vulnerability scanning
    Returns the path to the vulnerability report and any discovered redirect locations
    """
    # Create output file for vulnerability report
    timestamp = nmap_file.split("_")[-1].split(".")[
        0
    ]  # Extract timestamp from nmap filename
    vuln_file = output_dir / f"potential_vulns_{timestamp}.txt"

    # Get services from both nmap and whatweb
    nmap_services = parse_nmap_output(nmap_file)
    whatweb_services, redirect_locations = parse_whatweb_output(whatweb_file)

    # Combine all unique services
    all_services = nmap_services.union(whatweb_services)

    # Create vulnerability report header
    with open(vuln_file, "w") as f:
        f.write("Vulnerability Scan Report\n")
        f.write(f"Generated: {timestamp}\n\n")

        if redirect_locations:
            f.write("Suggested Hosts File Entries:\n")
            f.write("=" * 30 + "\n")
            for location in redirect_locations:
                f.write(f"Found redirect to: {location}\n")
            f.write("\n")

    # Run searchsploit against each service
    print("[*] Running vulnerability scans...")
    for service in all_services:
        print(f"[*] Scanning {service}")
        run_searchsploit(service, vuln_file)

    return str(vuln_file), redirect_locations
