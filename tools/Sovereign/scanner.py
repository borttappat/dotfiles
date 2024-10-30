#!/usr/bin/env python3
import argparse
import subprocess
import re
from pathlib import Path
from datetime import datetime
from vulnscan import scan_for_vulnerabilities


def run_nmap_scan(target, output_file):
    """
    Run nmap scan with specified parameters and save to output file.
    Parameters are set for aggressive web service discovery.
    """
    try:
        command = [
            "nmap",
            "-A",  # Aggressive scan
            "-p-",  # All ports
            "-T4",  # Aggressive timing
            "-oN",  # Output in normal format
            output_file,  # Output file
            target,  # Target IP/hostname
        ]

        print(f"[*] Starting scan against {target}")
        print(f"[*] Command: {' '.join(command)}")

        process = subprocess.run(command, capture_output=True, text=True, check=True)

        print(f"[+] Scan completed successfully. Results saved to {output_file}")
        return True

    except subprocess.CalledProcessError as e:
        print(f"[-] Error running nmap: {e}")
        print(f"[-] Error output: {e.stderr}")
        return False
    except Exception as e:
        print(f"[-] Unexpected error: {e}")
        return False


def identify_web_services(nmap_output):
    """
    Parse nmap output to identify web services.
    Returns a list of ports running web services.
    """
    web_ports = []
    web_services = ["http", "https", "http-alt", "http-proxy"]

    try:
        with open(nmap_output, "r") as f:
            for line in f:
                if any(service in line.lower() for service in web_services):
                    if "open" in line and "tcp" in line:
                        port = line.split("/")[0].strip()
                        web_ports.append(port)

        return web_ports

    except FileNotFoundError:
        print(f"[-] Error: Nmap output file {nmap_output} not found")
        return []
    except Exception as e:
        print(f"[-] Error parsing nmap output: {e}")
        return []


def format_whatweb_output(raw_output: str) -> str:
    """
    Format whatweb output to be more readable:
    - Split entries after each bracket+comma
    - Remove square brackets
    - Create clean list with one entry per line
    """
    formatted_lines = []
    current_url = ""

    for line in raw_output.split("\n"):
        if line.startswith("http"):
            if current_url:  # Add blank line between URLs
                formatted_lines.append("")
            current_url = line.split()[0]
            formatted_lines.append(f"Target: {current_url}")
            formatted_lines.append("-" * (len(current_url) + 8))

            # Process the rest of the line
            parts = re.findall(r"([^,\[]]+(?:\[[^\]]*\])?)", line.split(None, 1)[1])
            for part in parts:
                if "[" in part and "]" in part:
                    # Extract service and version from brackets
                    service_part = part.split("[", 1)
                    service = service_part[0].strip()
                    version = service_part[1].rstrip("]")
                    formatted_lines.append(f"{service}: {version}")

    return "\n".join(formatted_lines)


def run_whatweb(target, ports, output_file):
    """
    Run whatweb against discovered web services and save raw output to file
    """
    try:
        with open(output_file, "w") as f:
            for port in ports:
                target_url = f"http://{target}:{port}"
                command = ["whatweb", "--color=never", target_url]

                print(f"[*] Running whatweb against {target_url}")

                process = subprocess.run(
                    command, capture_output=True, text=True, check=True
                )

                if process.stdout:
                    f.write(process.stdout)
                else:
                    print(f"[-] No whatweb output for {target_url}")

        return True

    except subprocess.CalledProcessError as e:
        print(f"[-] Error running whatweb: {e}")
        return False
    except Exception as e:
        print(f"[-] Error: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Simple Nmap wrapper for web service enumeration"
    )
    parser.add_argument("target", help="Target IP address or hostname")
    args = parser.parse_args()

    # Create output directory
    output_dir = Path("scan_results")
    output_dir.mkdir(exist_ok=True)

    # Generate output filenames with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    nmap_output = output_dir / f"nmap_scan_{timestamp}.txt"

    # Run initial nmap scan
    if run_nmap_scan(args.target, str(nmap_output)):
        # Identify web services from nmap output
        web_ports = identify_web_services(nmap_output)

        if web_ports:
            print(f"[+] Discovered web services on ports: {', '.join(web_ports)}")

            # Run whatweb against discovered services
            whatweb_output = output_dir / f"whatweb_scan_{timestamp}.txt"
            if run_whatweb(args.target, web_ports, whatweb_output):
                print(f"[+] Whatweb results saved to {whatweb_output}")

                # Scan for vulnerabilities
                vuln_file, redirect_locations = scan_for_vulnerabilities(
                    str(nmap_output), str(whatweb_output), output_dir
                )

                print(f"[+] Vulnerability scan completed. Results saved to {vuln_file}")

                if redirect_locations:
                    print("\n[+] Suggested host file entries:")
                    for location in redirect_locations:
                        print(f"    {args.target} {location.split('://')[-1]}")
        else:
            print("[-] No web services discovered")


if __name__ == "__main__":
    main()
