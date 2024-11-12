#!/usr/bin/env python3
import argparse
import requests
import sublist3r
import sys
from urllib3.exceptions import InsecureRequestWarning
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

# Suppress SSL warnings
requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

def check_subdomain(subdomain, timeout=5):
    """Try to connect to a subdomain and return status code"""
    result = {'subdomain': subdomain, 'url': None, 'status': None, 'redirect': None}
    
    for protocol in ['https', 'http']:
        url = f"{protocol}://{subdomain}"
        try:
            response = requests.get(
                url,
                timeout=timeout,
                verify=False,
                allow_redirects=True
            )
            result.update({
                'url': url,
                'status': response.status_code,
                'redirect': response.url if response.url != url else None
            })
            return result
        except requests.RequestException:
            continue
    return result

def scan_from_wordlist(domain, wordlist_path, max_workers=10):
    """Scan subdomains using a wordlist with concurrent execution"""
    print(f"\nScanning with wordlist: {wordlist_path}")
    try:
        with open(wordlist_path, 'r') as f:
            subdomains = [f"{line.strip()}.{domain}" for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: Wordlist not found: {wordlist_path}")
        return []
        
    results = []
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_subdomain = {
            executor.submit(check_subdomain, subdomain): subdomain 
            for subdomain in subdomains
        }
        
        with tqdm(total=len(subdomains), desc="Scanning subdomains") as pbar:
            for future in as_completed(future_to_subdomain):
                result = future.result()
                if result['status'] is not None:
                    results.append(result)
                pbar.update(1)
                
                # Clear the current line to prevent trailing
                sys.stdout.write('\r' + ' ' * 80 + '\r')
                sys.stdout.flush()
    
    return results

def scan_with_sublist3r(domain, max_workers=10):
    """Scan subdomains using Sublist3r with concurrent validation"""
    print("\nRunning Sublist3r scan...")
    try:
        subdomains = sublist3r.main(
            domain,
            40,  # Sublist3r threads
            savefile=None,
            ports=None,
            silent=True,
            verbose=False,
            enable_bruteforce=False,
            engines=None
        )
    except Exception as e:
        print(f"Sublist3r error: {e}")
        return []

    results = []
    if subdomains:
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            future_to_subdomain = {
                executor.submit(check_subdomain, subdomain): subdomain 
                for subdomain in subdomains
            }
            
            with tqdm(total=len(subdomains), desc="Validating subdomains") as pbar:
                for future in as_completed(future_to_subdomain):
                    result = future.result()
                    if result['status'] is not None:
                        results.append(result)
                    pbar.update(1)
                    
                    # Clear the current line to prevent trailing
                    sys.stdout.write('\r' + ' ' * 80 + '\r')
                    sys.stdout.flush()
    
    return results

def print_results(results):
    """Print results in a clean format"""
    if not results:
        print("\nNo active subdomains found")
        return
        
    print("\nActive subdomains found:")
    print("-" * 80)
    
    # Sort results by status code
    results.sort(key=lambda x: (x['status'] if x['status'] else 999))
    
    for result in results:
        if not result['status']:
            continue
            
        # Status code color coding
        if 200 <= result['status'] < 300:
            color = '\033[92m'  # Green
        elif 300 <= result['status'] < 400:
            color = '\033[94m'  # Blue
        elif 400 <= result['status'] < 500:
            color = '\033[93m'  # Yellow
        else:
            color = '\033[91m'  # Red
            
        reset = '\033[0m'
        
        # Format output line
        line = f"{color}[{result['status']}]{reset} {result['url']}"
        if result.get('redirect'):
            line += f" → {result['redirect']}"
            
        print(line)
        sys.stdout.flush()  # Ensure immediate output

def save_results(results, output_file):
    """Save results to a file"""
    if not results:
        return
        
    try:
        with open(output_file, 'w') as f:
            for result in results:
                if result['status']:
                    line = f"{result['status']} {result['url']}"
                    if result.get('redirect'):
                        line += f" → {result['redirect']}"
                    f.write(line + '\n')
        
        print(f"\nResults saved to {output_file}")
    except Exception as e:
        print(f"\nError saving results: {e}")

def main():
    parser = argparse.ArgumentParser(description="Enhanced subdomain enumeration tool")
    parser.add_argument("domain", help="Target domain (e.g., example.com)")
    parser.add_argument("-w", "--wordlist", help="Path to wordlist file")
    parser.add_argument("-o", "--output", help="Output file for results")
    parser.add_argument("--no-sublist3r", action="store_true", 
                       help="Disable Sublist3r scan")
    parser.add_argument("--threads", type=int, default=10,
                       help="Number of concurrent threads (default: 10)")
    parser.add_argument("--timeout", type=int, default=5,
                       help="Timeout for HTTP requests in seconds (default: 5)")
    
    args = parser.parse_args()
    
    try:
        all_results = []
        
        # Run Sublist3r scan if enabled
        if not args.no_sublist3r:
            results = scan_with_sublist3r(args.domain, args.threads)
            all_results.extend(results)
        
        # Run wordlist scan if wordlist provided
        if args.wordlist:
            results = scan_from_wordlist(args.domain, args.wordlist, args.threads)
            all_results.extend(results)
        
        # Remove duplicates while preserving order
        seen = set()
        unique_results = []
        for result in all_results:
            if result['url'] not in seen and result['status'] is not None:
                seen.add(result['url'])
                unique_results.append(result)
        
        # Print and save results
        print_results(unique_results)
        if args.output:
            save_results(unique_results, args.output)
            
    except KeyboardInterrupt:
        print("\nScan interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\nError: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
