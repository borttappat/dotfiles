#!/usr/bin/env python3
import argparse
import requests
import sublist3r
from urllib3.exceptions import InsecureRequestWarning

# Suppress SSL warnings
requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

def check_subdomain(subdomain):
    """Try to connect to a subdomain and return status code"""
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
    """Scan subdomains using a wordlist"""
    print(f"\nScanning with wordlist: {wordlist_path}")
    try:
        with open(wordlist_path, 'r') as f:
            subdomains = [f"{line.strip()}.{domain}" for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: Wordlist not found: {wordlist_path}")
        return []
        
    results = []
    total = len(subdomains)
    
    for i, subdomain in enumerate(subdomains, 1):
        print(f"Checking {i}/{total}: {subdomain}", end='\r')
        result = check_subdomain(subdomain)
        if result:
            results.append({'subdomain': subdomain, **result})
            
    print("\nWordlist scan complete")
    return results

def scan_with_sublist3r(domain):
    """Scan subdomains using Sublist3r"""
    print("\nRunning Sublist3r scan...")
    subdomains = sublist3r.main(
        domain,
        40,  # number of threads Sublist3r uses internally
        savefile=None,
        ports=None,
        silent=True,
        verbose=False,
        enable_bruteforce=False,
        engines=None
    )
    
    results = []
    if subdomains:
        total = len(subdomains)
        for i, subdomain in enumerate(subdomains, 1):
            print(f"Checking {i}/{total}: {subdomain}", end='\r')
            result = check_subdomain(subdomain)
            if result:
                results.append({'subdomain': subdomain, **result})
                
    print("\nSublist3r scan complete")
    return results

def print_results(results):
    """Print results in a simple format"""
    if not results:
        print("\nNo active subdomains found")
        return
        
    print("\nActive subdomains found:")
    print("-" * 60)
    
    for result in results:
        # Color based on status code
        if 200 <= result['status'] < 300:
            color = '\033[92m'  # Green
        elif 300 <= result['status'] < 400:
            color = '\033[94m'  # Blue
        elif 400 <= result['status'] < 500:
            color = '\033[93m'  # Yellow
        else:
            color = '\033[91m'  # Red
            
        reset = '\033[0m'
        
        print(f"{color}[{result['status']}]{reset} {result['url']}", end='')
        if result.get('redirect'):
            print(f" → {result['redirect']}")
        else:
            print()

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

def main():
    parser = argparse.ArgumentParser(description="Simple subdomain enumeration tool")
    parser.add_argument("domain", help="Target domain (e.g., example.com)")
    parser.add_argument("-w", "--wordlist", help="Path to wordlist file")
    parser.add_argument("-o", "--output", help="Output file for results")
    parser.add_argument("--no-sublist3r", action="store_true", 
                       help="Disable Sublist3r scan")
    
    args = parser.parse_args()
    
    all_results = []
    
    # Run Sublist3r scan if enabled
    if not args.no_sublist3r:
        results = scan_with_sublist3r(args.domain)
        all_results.extend(results)
    
    # Run wordlist scan if wordlist provided
    if args.wordlist:
        results = scan_from_wordlist(args.domain, args.wordlist)
        all_results.extend(results)
    
    # Remove duplicates while preserving order
    seen = set()
    unique_results = []
    for result in all_results:
        if result['url'] not in seen:
            seen.add(result['url'])
            unique_results.append(result)
    
    # Print and save results
    print_results(unique_results)
    if args.output:
        save_results(unique_results, args.output)

if __name__ == "__main__":
    main()
