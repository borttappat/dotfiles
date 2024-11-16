#!/usr/bin/env python3
import argparse
import requests
import dns.resolver
from urllib3.exceptions import InsecureRequestWarning

# Suppress SSL warnings
requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

def check_subdomain(subdomain):
    """
    Check if a subdomain exists by trying DNS resolution and HTTP/HTTPS connection
    Returns None if the subdomain doesn't resolve or respond
    """
    try:
        # Try DNS resolution first
        dns.resolver.resolve(subdomain, 'A')
    except:
        return None

    # Try HTTPS first, then HTTP if HTTPS fails
    for protocol in ['https', 'http']:
        url = f"{protocol}://{subdomain}"
        try:
            response = requests.get(
                url,
                timeout=5,
                verify=False,
                allow_redirects=True
            )
            return {
                'url': url,
                'status': response.status_code,
                'redirect': response.url if response.url != url else None
            }
        except requests.RequestException:
            continue
    return None

def scan_from_wordlist(domain, wordlist_path):
    """
    Simple wordlist-based subdomain enumeration
    """
    print(f"\nStarting wordlist scan for {domain}")
    results = []
    
    try:
        with open(wordlist_path, 'r') as f:
            for line in f:
                subdomain = f"{line.strip()}.{domain}"
                print(f"Checking: {subdomain}")
                
                result = check_subdomain(subdomain)
                if result:
                    results.append({'subdomain': subdomain, **result})
                    print(f"Found: {subdomain} ({result['status']})")
    except FileNotFoundError:
        print(f"Error: Wordlist not found: {wordlist_path}")
    
    return results

def save_results(results, output_file):
    """Save results to a file"""
    if not results:
        return
        
    with open(output_file, 'w') as f:
        for result in results:
            f.write(f"{result['status']} {result['url']}")
            if result.get('redirect'):
                f.write(f" → {result['redirect']}")
            f.write('\n')
    
    print(f"\nResults saved to {output_file}")

def print_results(results):
    """Print results in a readable format"""
    if not results:
        print("\nNo active subdomains found")
        return
        
    print("\nActive subdomains found:")
    print("-" * 60)
    
    for result in results:
        print(f"[{result['status']}] {result['url']}", end='')
        if result.get('redirect'):
            print(f" → {result['redirect']}")
        else:
            print()

def main():
    parser = argparse.ArgumentParser(description="Simple subdomain enumeration tool")
    parser.add_argument("domain", help="Target domain (e.g., example.com)")
    parser.add_argument("-w", "--wordlist", required=True, 
                       help="Path to wordlist file")
    parser.add_argument("-o", "--output", help="Output file for results")
    
    args = parser.parse_args()
    
    # Run wordlist scan
    results = scan_from_wordlist(args.domain, args.wordlist)
    
    # Print and save results
    print_results(results)
    if args.output:
        save_results(results, args.output)

if __name__ == "__main__":
    main()
