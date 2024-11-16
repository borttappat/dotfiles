#!/usr/bin/env python3
import argparse
import requests
import dns.resolver
from urllib3.exceptions import InsecureRequestWarning
from typing import Optional, Dict, List
from pathlib import Path

# Suppress SSL warnings
requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

def check_vhost(ip: str, hostname: str, timeout: int = 5) -> Optional[Dict]:
    """
    Enhanced vhost checking specifically for CTF scenarios
    """
    headers = {
        'Host': hostname,
        'User-Agent': 'Mozilla/5.0',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Connection': 'close'
    }
    
    # For CTF, we'll store more response details for analysis
    for protocol in ['http', 'https']:  # Try HTTP first in CTF scenarios
        url = f"{protocol}://{ip}"
        try:
            # Get baseline response without Host header
            baseline = requests.get(
                url,
                timeout=timeout,
                verify=False,
                allow_redirects=False
            )
            
            # Get response with Host header
            response = requests.get(
                url,
                headers=headers,
                timeout=timeout,
                verify=False,
                allow_redirects=False
            )
            
            # Enhanced comparison for CTF scenarios
            if (len(response.content) != len(baseline.content) or
                response.status_code != baseline.status_code or
                any(keyword in response.text.lower() 
                    for keyword in ['login', 'admin', 'dashboard', 'welcome'])):
                
                return {
                    'hostname': hostname,
                    'ip': ip,
                    'protocol': protocol,
                    'status': response.status_code,
                    'size': len(response.content),
                    'baseline_size': len(baseline.content),
                    'baseline_status': baseline.status_code,
                    'url': url,
                    'title': extract_title(response.text) if 'text/html' in response.headers.get('Content-Type', '') else None
                }
                
        except requests.RequestException:
            continue
    return None

def extract_title(html_content: str) -> Optional[str]:
    """Extract title from HTML content"""
    import re
    title_match = re.search(r'<title>(.*?)</title>', html_content, re.IGNORECASE)
    return title_match.group(1) if title_match else None

def generate_hostnames(word: str, base_domain: str = None) -> List[str]:
    """Generate CTF-focused hostname patterns"""
    hostnames = []
    
    # Basic patterns
    if base_domain:
        hostnames.extend([
            f"{word}.{base_domain}",          # word.permx
            f"{word}.{base_domain}.htb",      # word.permx.htb
        ])
    
    # Common CTF patterns
    hostnames.extend([
        word,                    # just the word
        f"{word}.htb",          # word.htb
        f"{word}.local",        # word.local
    ])
    
    # Common web service patterns
    if word not in ['www', 'dev', 'admin']:  # Avoid redundancy
        for prefix in ['dev-', 'test-', 'staging-']:
            hostnames.append(f"{prefix}{word}")
    
    return hostnames

def print_results(dns_results: List[Dict], vhost_results: List[Dict]):
    """Print only findings with status code 200"""
    GREEN = '\033[92m'
    RESET = '\033[0m'
    
    if vhost_results:
        # Filter for status 200 only
        hits = [r for r in vhost_results if r['status'] == 200]
        
        if hits:
            print("\nFound Virtual Hosts:")
            print("-" * 60)
            
            for result in hits:
                print(f"\n{GREEN}[+] {result['hostname']}{RESET}")
                print(f"Title: {result.get('title', 'N/A')}")
                print(f"Size: {result['size']:,} bytes")

def save_results(dns_results: List[Dict], vhost_results: List[Dict], output_file: str):
    """Save only findings with status code 200"""
    with open(output_file, 'w') as f:
        if vhost_results:
            hits = [r for r in vhost_results if r['status'] == 200]
            
            if hits:
                f.write("Found Virtual Hosts:\n")
                f.write("-" * 60 + "\n\n")
                
                for result in hits:
                    f.write(f"[+] {result['hostname']}\n")
                    f.write(f"Title: {result.get('title', 'N/A')}\n")
                    f.write(f"Size: {result['size']:,} bytes\n")
                    f.write("-" * 40 + "\n")
    
    print(f"\nResults saved to {output_file}")

def save_results(dns_results: List[Dict], vhost_results: List[Dict], output_file: str):
    """Save all results to a file, sorted by relevance"""
    with open(output_file, 'w') as f:
        if vhost_results:
            f.write("Virtual Host Results:\n")
            f.write("-" * 60 + "\n\n")
            
            # Sort results same as print_results
            sorted_results = sorted(
                vhost_results,
                key=lambda x: (
                    0 if x['status'] == 200 else 1,
                    -abs(x['size'] - x['baseline_size'])
                )
            )
            
            for result in sorted_results:
                size_diff = abs(result['size'] - result['baseline_size'])
                
                # Mark significant findings
                if result['status'] == 200 or size_diff > 1000:
                    f.write("[+] Significant Finding:\n")
                else:
                    f.write("Potential Finding:\n")
                    
                f.write(f"Hostname: {result['hostname']}\n")
                f.write(f"Status: {result['status']} (Baseline: {result['baseline_status']})\n")
                f.write(f"Response size: {result['size']:,} bytes\n")
                f.write(f"Size difference: {size_diff:,} bytes\n")
                if result.get('title'):
                    f.write(f"Page title: {result['title']}\n")
                f.write("-" * 40 + "\n")
        
        if dns_results:
            f.write("\nDNS Enumeration Results:\n")
            f.write("-" * 60 + "\n")
            for result in dns_results:
                f.write(f"Domain: {result['domain']} ({', '.join(result.get('ips', []))})\n")
                if result.get('url'):
                    f.write(f"URL: {result['url']} (Status: {result['status']})\n")
                    if result.get('redirect'):
                        f.write(f"Redirects to: {result['redirect']}\n")
                f.write("-" * 40 + "\n")
    
    print(f"\nResults saved to {output_file}")

def scan_target(target: str, wordlist_path: str, mode: str = 'auto', base_domain: str = None) -> tuple:
    """
    Enhanced scanning function with CTF focus
    """
    results_dns = []
    results_vhost = []
    
    try:
        with open(wordlist_path, 'r') as f:
            words = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: Wordlist not found: {wordlist_path}")
        return results_dns, results_vhost

    # Auto-detect mode
    if mode == 'auto':
        mode = 'vhost' if target.replace('.', '').isdigit() else 'dns'
    
    total = len(words)
    print(f"\nStarting {mode} scan for {target}")
    
    if mode == 'vhost':
        target_ip = target
        for i, word in enumerate(words, 1):
            print(f"Progress: {i}/{total} - Testing {word}", end='\r')
            
            for hostname in generate_hostnames(word, base_domain):
                result = check_vhost(target_ip, hostname)
                if result:
                    results_vhost.append(result)
                    diff = abs(result['baseline_size'] - result['size'])
                    title = f" - {result['title']}" if result['title'] else ""
                    print(f"\nFound vhost: {hostname}{title}")
                    print(f"Size diff: {diff} bytes (Baseline: {result['baseline_size']}, Response: {result['size']})")
                    print(f"Status codes: Baseline {result['baseline_status']}, Response {result['status']}")
    
    else:  # dns mode
        # Implement DNS scanning if needed
        pass
    
    print("\nScan completed!")
    return results_dns, results_vhost

def main():
    parser = argparse.ArgumentParser(
        description="Virtual Host enumeration tool for CTF environments")
    parser.add_argument("target", 
                       help="Target IP address or domain (e.g., 10.10.11.23 or permx.htb)")
    parser.add_argument("-w", "--wordlist", required=True, 
                       help="Path to wordlist file")
    parser.add_argument("-m", "--mode", choices=['auto', 'dns', 'vhost'],
                       default='vhost',  # Changed default to vhost for CTF focus
                       help="Scan mode (default: vhost)")
    parser.add_argument("-o", "--output", help="Output file for results")
    parser.add_argument("-b", "--base-domain",
                       help="Base domain for vhost enumeration (e.g., 'permx' for word.permx.htb)")
    
    args = parser.parse_args()
    
    # Run scan
    dns_results, vhost_results = scan_target(args.target, args.wordlist, 
                                           args.mode, args.base_domain)
    
    # Print and save results
    print_results(dns_results, vhost_results)
    if args.output:
        save_results(dns_results, vhost_results, args.output)

if __name__ == "__main__":
    main()
