#!/usr/bin/env python3

import nmap
import json
import os
import sys
from datetime import datetime
from pathlib import Path

class SubnetMonitor:
    def __init__(self, subnets, known_hosts_file=os.path.expanduser("~/Boxes/known-hosts.txt")):
        self.subnets = subnets
        self.known_hosts_file = known_hosts_file
        self.nm = nmap.PortScanner()
        self.known_hosts = self.load_known_hosts()

    def load_known_hosts(self):
        """Load the known hosts from the JSON file, or create an empty list if file doesn't exist."""
        if os.path.exists(self.known_hosts_file):
            try:
                with open(self.known_hosts_file, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                print(f"Error parsing {self.known_hosts_file}, starting with empty known hosts list")
                return {}
        return {}

    def save_known_hosts(self):
        """Save the known hosts to the JSON file."""
        with open(self.known_hosts_file, 'w') as f:
            json.dump(self.known_hosts, f, indent=2)

    def scan_subnet(self, subnet):
        """Scan a subnet for hosts and return the results."""
        print(f"Scanning subnet {subnet}...")
        # -sn: Ping scan - disable port scan
        # -T4: Aggressive timing template
        self.nm.scan(hosts=subnet, arguments='-sn -T4')
        return self.nm.all_hosts()

    def scan_all_subnets(self):
        """Scan all subnets and identify new hosts."""
        all_hosts = []
        new_hosts = []

        for subnet in self.subnets:
            hosts = self.scan_subnet(subnet)
            all_hosts.extend(hosts)
            
            # Check if any of these hosts are new
            for host in hosts:
                if host not in self.known_hosts:
                    try:
                        hostname = self.nm[host].hostname()
                    except:
                        hostname = "unknown"
                    
                    # Get current timestamp
                    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    
                    new_hosts.append({
                        'ip': host,
                        'hostname': hostname,
                        'first_seen': timestamp
                    })

        return all_hosts, new_hosts

    def prompt_for_new_hosts(self, new_hosts):
        """Ask the user if they want to add new hosts to the known list."""
        if not new_hosts:
            print("No new hosts found.")
            return

        print("\n==== New Hosts Detected ====")
        for i, host in enumerate(new_hosts):
            print(f"{i+1}. IP: {host['ip']} - Hostname: {host['hostname']} - First seen: {host['first_seen']}")
        
        for host in new_hosts:
            response = input(f"\nAdd {host['ip']} ({host['hostname']}) to known hosts? (y/n): ").lower()
            if response == 'y' or response == 'yes':
                self.known_hosts[host['ip']] = {
                    'hostname': host['hostname'],
                    'first_seen': host['first_seen']
                }
                print(f"Added {host['ip']} to known hosts.")
            else:
                print(f"Skipped {host['ip']}.")
        
        self.save_known_hosts()

    def show_all_known_hosts(self):
        """Display all known hosts."""
        if not self.known_hosts:
            print("No known hosts.")
            return

        print("\n==== Known Hosts ====")
        for ip, info in self.known_hosts.items():
            hostname = info.get('hostname', 'unknown')
            first_seen = info.get('first_seen', 'unknown')
            print(f"IP: {ip} - Hostname: {hostname} - First seen: {first_seen}")

    def run(self):
        """Run the subnet monitor."""
        all_hosts, new_hosts = self.scan_all_subnets()
        
        print(f"\nFound {len(all_hosts)} hosts total across all subnets.")
        print(f"Detected {len(new_hosts)} new hosts.")
        
        self.prompt_for_new_hosts(new_hosts)
        self.show_all_known_hosts()


if __name__ == "__main__":
    # List of subnets to monitor
    subnets = [
        "10.3.10.0/24",
        "10.9.10.0/24", 
        "10.4.10.0/24"
    ]
    
    # Create and run the subnet monitor
    monitor = SubnetMonitor(subnets)
    monitor.run()
