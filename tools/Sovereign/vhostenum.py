#!/usr/bin/env python3
import argparse
import asyncio
import aiohttp
from typing import List, Dict, Optional
from pathlib import Path
import sys
from tqdm import tqdm

async def check_vhost(session: aiohttp.ClientSession, ip: str, word: str, domain: str, debug: bool = False) -> Optional[Dict]:
    """Check virtual host with improved reliability"""
    hostname = f"{word}.{domain}"
    url = f"http://{ip}"
    
    headers = {
        'Host': hostname,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Connection': 'close'
    }
    
    try:
        async with session.get(url, 
                             headers=headers, 
                             ssl=False, 
                             timeout=3,
                             allow_redirects=False) as response:
            
            content = await response.text()
            size = len(content)
            
            if response.status == 200:
                return {
                    'hostname': hostname,
                    'status': response.status,
                    'size': size,
                    'url': f"http://{hostname}", 
                    'title': extract_title(content) if 'text/html' in response.headers.get('Content-Type', '').lower() else None
                }
                
    except Exception as e:
        if debug:
            print(f"Error for {hostname}: {str(e)}")
    
    return None

def extract_title(html_content: str) -> Optional[str]:
    """Extract title from HTML content"""
    import re
    try:
        title_match = re.search(r'<title>(.*?)</title>', html_content, re.IGNORECASE)
        return title_match.group(1).strip() if title_match else None
    except Exception:
        return None

async def process_chunk(session: aiohttp.ClientSession, ip: str, domain: str, 
                       words: List[str], pbar: tqdm, debug: bool = False) -> List[Dict]:
    """Process a chunk of words"""
    tasks = []
    results = []
    
    for word in words:
        task = asyncio.create_task(check_vhost(session, ip, word, domain, debug))
        tasks.append(task)
    
    for task in asyncio.as_completed(tasks):
        try:
            result = await task
            pbar.update(1)
            if result:
                results.append(result)
                print(f"\r[+] Found: {result['url']} ({result['size']:,} bytes)")
        except Exception as e:
            if debug:
                print(f"\nError in task: {str(e)}")
    
    return results

async def scan_target(ip: str, domain: str, wordlist_path: str, 
                     concurrent: int = 30, delay: float = 0.1, debug: bool = False) -> List[Dict]:
    """Scan target with chunked processing"""
    try:
        with open(wordlist_path, 'r') as f:
            words = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: Wordlist not found: {wordlist_path}")
        return []
    
    if not words:
        print("Error: Wordlist is empty")
        return []

    results = []
    total = len(words)
    
    print(f"\nTarget: {ip} ({domain})")
    print(f"Wordlist: {wordlist_path} ({total} words)")
    if debug:
        print("Debug mode: ON")
    
    chunk_size = concurrent
    chunks = [words[i:i + chunk_size] for i in range(0, len(words), chunk_size)]
    
    connector = aiohttp.TCPConnector(
        limit=concurrent,
        ttl_dns_cache=300,
        force_close=True
    )
    
    timeout = aiohttp.ClientTimeout(total=3, connect=2)
    
    async with aiohttp.ClientSession(connector=connector, timeout=timeout) as session:
        with tqdm(total=total, desc="Scanning", unit=" hosts", 
                 ncols=80, bar_format='{l_bar}{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}]') as pbar:
            for chunk in chunks:
                chunk_results = await process_chunk(session, ip, domain, chunk, pbar, debug)
                results.extend(chunk_results)
                if delay:
                    await asyncio.sleep(delay)
    
    return results

def print_results(results: List[Dict]):
    """Print findings with URLs"""
    GREEN = '\033[92m'
    RESET = '\033[0m'
    
    if results:
        print("\nConfirmed Virtual Hosts:")
        print("-" * 60)
        
        # First print full findings
        for result in sorted(results, key=lambda x: x['hostname']):
            print(f"\n{GREEN}[+] {result['url']}{RESET}")
            print(f"Status: {result['status']}")
            print(f"Size: {result['size']:,} bytes")
            if result.get('title'):
                print(f"Title: {result['title']}")
        
        # Then print just the URLs for easy copying
        print("\nDiscovered URLs:")
        print("-" * 60)
        for result in sorted(results, key=lambda x: x['hostname']):
            print(result['url'])
    else:
        print("\nNo virtual hosts found")

async def main():
    parser = argparse.ArgumentParser(
        description="Fast virtual host scanner with progress bar")
    parser.add_argument("ip", help="Target IP address")
    parser.add_argument("domain", help="Base domain (e.g., 'permx.htb')")
    parser.add_argument("-w", "--wordlist", required=True, 
                       help="Path to wordlist file")
    parser.add_argument("-c", "--concurrent", type=int, default=30,
                       help="Maximum concurrent requests (default: 30)")
    parser.add_argument("-d", "--delay", type=float, default=0.1,
                       help="Delay between chunks in seconds (default: 0.1)")
    parser.add_argument("--debug", action="store_true",
                       help="Enable debug output")
    
    args = parser.parse_args()
    
    try:
        results = await scan_target(
            args.ip, args.domain, args.wordlist,
            args.concurrent, args.delay, args.debug
        )
        print_results(results)
    except KeyboardInterrupt:
        print("\nScan interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\nError: {str(e)}")
        if args.debug:
            import traceback
            traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
