#!/usr/bin/env python3

import os
import sys
import json
import argparse
import subprocess
import time
import gc
from pathlib import Path
from typing import List, Dict, Optional, Tuple

try:
    import requests
    from rich.console import Console
    from rich.panel import Panel
    from rich.markdown import Markdown
    from rich.theme import Theme
except ImportError:
    print("Missing required packages. Please install: requests, rich")
    sys.exit(1)

# Define custom theme to ensure formatting works correctly
custom_theme = Theme({
    "info": "cyan",
    "warning": "yellow",
    "danger": "bold red",
    "success": "bold green",
})

# Initialize rich console with appropriate settings
console = Console(theme=custom_theme, highlight=False)

# Constants
CONFIG_DIR = Path.home() / ".config" / "nixllm"
CONFIG_FILE = CONFIG_DIR / "config.json"
API_KEY_FILE = CONFIG_DIR / "api_key"
HISTORY_FILE = CONFIG_DIR / "history.json"
INDEX_FILE = CONFIG_DIR / "file_index.json"
INDEX_DECISIONS_FILE = CONFIG_DIR / "index_decisions.json"
MAX_HISTORY_ENTRIES = 100
DOTFILES_PATH = Path.home() / "dotfiles"

# Default configuration
DEFAULT_CONFIG = {
    "model": "mistral-medium",
    "max_commands": 5,
    "safe_mode": True,
    "max_tokens": 2000,
    "temperature": 0.2,
    "index_max_file_size_mb": 2,  # 2MB default
    "index_max_dir_size_mb": 10,  # 10MB default
    "system_prompt": """
    You are NixLLM, a shell command assistant for NixOS systems. When the user asks a question:
    1. Interpret what they want to accomplish on their NixOS system
    2. Generate {max_commands} possible shell commands that could help them
    3. For each command, provide a brief one-line description of what it does
    4. Return your response in the following JSON format:
    {{
        "commands": [
            {{
                "command": "actual shell command here",
                "description": "Brief explanation of what this command does"
            }},
            ...
        ],
        "explanation": "Overall explanation of the approach"
    }}
    
    Focus on commands that are compatible with NixOS and are safe to execute. Avoid destructive commands unless clearly requested.
    Important: Never suggest 'nix run' or similar commands for packages that are likely already installed, like common utilities.
    """
}

class NixLLM:
    def __init__(self):
        self.config = self.load_config()
        self.api_key = self.load_api_key()
        self.history = self.load_history()
        
        # Load file index from disk if available
        self.file_index = self.load_file_index()
        
        # Get installed packages
        self.installed_packages = self.get_installed_packages()
    
    def load_config(self) -> Dict:
        """Load configuration file or create a default one if not exists"""
        if not CONFIG_DIR.exists():
            CONFIG_DIR.mkdir(parents=True)
        
        if not CONFIG_FILE.exists():
            with open(CONFIG_FILE, 'w') as f:
                json.dump(DEFAULT_CONFIG, f, indent=2)
            console.print(f"Created default configuration at {CONFIG_FILE}")
        
        with open(CONFIG_FILE, 'r') as f:
            config = json.load(f)
            
        return config
    
    def load_api_key(self) -> str:
        """Load API key from separate file"""
        if not API_KEY_FILE.exists():
            console.print(f"API key file not found at {API_KEY_FILE}", style="danger")
            console.print("Please run with --setup to configure your API key.")
            sys.exit(1)
        
        with open(API_KEY_FILE, 'r') as f:
            api_key = f.read().strip()
            
        if not api_key:
            console.print("API key is empty.", style="danger")
            console.print(f"Please add your API key to {API_KEY_FILE}.")
            sys.exit(1)
            
        return api_key
    
    def save_api_key(self, api_key: str):
        """Save API key to file with restricted permissions"""
        with open(API_KEY_FILE, 'w') as f:
            f.write(api_key)
        # Set restricted permissions (read/write only for the owner)
        API_KEY_FILE.chmod(0o600)
    
    def load_history(self) -> List[Dict]:
        """Load command history from file"""
        if not HISTORY_FILE.exists():
            return []
        
        try:
            with open(HISTORY_FILE, 'r') as f:
                return json.load(f)
        except json.JSONDecodeError:
            return []
    
    def save_history(self):
        """Save command history to file"""
        with open(HISTORY_FILE, 'w') as f:
            json.dump(self.history[-MAX_HISTORY_ENTRIES:], f, indent=2)
    
    def add_to_history(self, query: str, command: str):
        """Add a command to history"""
        self.history.append({
            "query": query,
            "command": command,
            "timestamp": time.time()
        })
        self.save_history()
    
    def load_file_index(self) -> Optional[Dict]:
        """Load file index from disk if available"""
        if INDEX_FILE.exists():
            try:
                with open(INDEX_FILE, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                return None
        return None
    
    def save_file_index(self, index: Dict):
        """Save file index to disk"""
        with open(INDEX_FILE, 'w') as f:
            json.dump(index, f, indent=2)
    
    def load_indexing_decisions(self) -> Dict:
        """Load saved user decisions about what to index"""
        if INDEX_DECISIONS_FILE.exists():
            try:
                with open(INDEX_DECISIONS_FILE, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                return {}
        return {}
    
    def save_indexing_decisions(self, decisions: Dict):
        """Save user decisions about what to index"""
        with open(INDEX_DECISIONS_FILE, 'w') as f:
            json.dump(decisions, f, indent=2)
    
    def should_index_path(self, path, size_threshold=None):
        """Ask user whether to index a large directory/file"""
        if size_threshold is None:
            # Convert MB to bytes
            if path.is_dir():
                size_threshold = self.config.get("index_max_dir_size_mb", 10) * 1024 * 1024
            else:
                size_threshold = self.config.get("index_max_file_size_mb", 2) * 1024 * 1024
        
        # Check saved decisions
        decisions = self.load_indexing_decisions()
        path_str = str(path)
        
        if path_str in decisions:
            return decisions[path_str]
        
        # Check directory size (approximately)
        if path.is_dir():
            # Just check the first level for speed
            size = sum(f.stat().st_size for f in path.glob('*') if f.is_file())
            if size > size_threshold:
                console.print(f"Large directory detected: {path}", style="warning")
                choice = input(f"Index this directory? (y/n/always/never): ").lower()
                if choice in ('always', 'never'):
                    decisions[path_str] = choice == 'always'
                    self.save_indexing_decisions(decisions)
                return choice in ('y', 'yes', 'always')
        
        # Check file size
        elif path.is_file():
            try:
                if path.stat().st_size > size_threshold:
                    console.print(f"Large file detected: {path}", style="warning")
                    choice = input(f"Index this file? (y/n/always/never): ").lower()
                    if choice in ('always', 'never'):
                        decisions[path_str] = choice == 'always'
                        self.save_indexing_decisions(decisions)
                    return choice in ('y', 'yes', 'always')
            except (OSError, PermissionError):
                return False
        
        return True
    
    def get_installed_packages(self) -> List[str]:
        """Get a list of installed packages"""
        packages = []
        
        # Try nix-env first
        try:
            result = subprocess.run(['nix-env', '-q'], capture_output=True, text=True, check=False)
            if result.returncode == 0:
                packages.extend(result.stdout.strip().splitlines())
        except:
            pass
        
        # Also try common programs that are likely installed
        common_programs = ["feh", "vim", "git", "firefox", "curl", "wget"]
        for program in common_programs:
            try:
                result = subprocess.run(['which', program], capture_output=True, text=True, check=False)
                if result.returncode == 0:
                    packages.append(program)
            except:
                pass
        
        return packages
    
    def index_home_directory(self, force_reindex=False, update_only=False):
        """Index files in the user's home directory for reference"""
        console.print("Indexing home directory...", style="info")
        
        # Start with empty or existing index
        if force_reindex:
            index = {"files": {}, "indexed_at": time.time()}
        elif update_only and self.file_index:
            index = self.file_index
        else:
            index = {"files": {}, "indexed_at": time.time()}
        
        # Define filters
        ignored_dirs = {".git", "node_modules", "__pycache__", ".venv", "venv", ".cache", "seclists"}
        ignored_exts = {".pyc", ".pyo", ".o", ".so", ".dll", ".exe", ".bin", ".dat", ".bak", ".tmp", ".swp"}
        max_file_size = self.config.get("index_max_file_size_mb", 2) * 1024 * 1024  # Convert MB to bytes
        
        # Track statistics for feedback
        stats = {
            "files_checked": 0,
            "files_indexed": 0,
            "files_skipped": 0,
            "dirs_skipped": 0
        }
        
        home_dir = Path.home()
        
        # Use os.walk for better memory efficiency
        for root, dirs, files in os.walk(home_dir, topdown=True, followlinks=False):
            # Skip ignored directories
            dirs[:] = [d for d in dirs if d not in ignored_dirs and not d.startswith('.')]
            
            # Check if we should index this directory at all
            root_path = Path(root)
            if not self.should_index_path(root_path):
                stats["dirs_skipped"] += 1
                dirs[:] = []  # Skip subdirectories
                continue
            
            for file in files:
                stats["files_checked"] += 1
                
                # Periodically report progress and release memory
                if stats["files_checked"] % 100 == 0:
                    console.print(f"Checked {stats['files_checked']} files, indexed {stats['files_indexed']}...", style="info")
                    gc.collect()  # Release memory
                
                try:
                    file_path = Path(root) / file
                    
                    # Skip symlinks
                    if file_path.is_symlink():
                        stats["files_skipped"] += 1
                        continue
                    
                    # Skip files based on extension
                    if any(file.endswith(ext) for ext in ignored_exts) or file.startswith('.'):
                        stats["files_skipped"] += 1
                        continue
                    
                    # Skip binary/large files
                    try:
                        if file_path.stat().st_size > max_file_size:
                            if not self.should_index_path(file_path):
                                stats["files_skipped"] += 1
                                continue
                    except (FileNotFoundError, PermissionError, OSError):
                        stats["files_skipped"] += 1
                        continue
                    
                    # Calculate relative path
                    rel_path = str(file_path.relative_to(home_dir))
                    abs_path = str(file_path)
                    
                    # Skip if already indexed and not forcing reindex
                    if update_only and rel_path in index["files"]:
                        try:
                            # Check if modified since last indexing
                            if file_path.stat().st_mtime <= index["files"][rel_path].get("modified", 0):
                                continue
                        except (OSError, PermissionError):
                            continue
                    
                    # Read file preview
                    try:
                        with open(file_path, 'r', errors='ignore') as f:
                            preview = f.read(1000)  # First 1000 chars
                            
                            # Store file info with minimal data
                            index["files"][rel_path] = {
                                "path": abs_path,
                                "modified": file_path.stat().st_mtime,
                                "size": file_path.stat().st_size,
                                "preview": preview[:1000]  # Limit preview size
                            }
                            
                            stats["files_indexed"] += 1
                    except (UnicodeDecodeError, IsADirectoryError, PermissionError, OSError):
                        stats["files_skipped"] += 1
                        continue
                        
                except Exception as e:
                    stats["files_skipped"] += 1
                    continue
        
        # Add additional system information
        index["system_info"] = self.get_system_info()
        
        # Add dotfiles structure if it exists
        if DOTFILES_PATH.exists():
            index["dotfiles_path"] = str(DOTFILES_PATH)
            
            # Add directory structure information for dotfiles
            index["dotfiles_structure"] = {}
            for dir_path in ["modules", "scripts/bash", "scripts/python"]:
                full_path = DOTFILES_PATH / dir_path
                if full_path.exists():
                    index["dotfiles_structure"][dir_path] = [
                        f.name for f in full_path.glob("*") if f.is_file()
                    ]
        
        # Save the index to disk
        self.save_file_index(index)
        
        # Update in-memory reference
        self.file_index = index
        
        console.print(f"Indexed {stats['files_indexed']} files in home directory", style="success")
        console.print(f"Skipped {stats['files_skipped']} files and {stats['dirs_skipped']} directories", style="info")
        
        # Force garbage collection to reclaim memory
        gc.collect()
        
        return index
    
    def get_system_info(self) -> Dict:
        """Get system information for context"""
        info = {}
        
        # Get NixOS version
        try:
            with open("/etc/os-release", "r") as f:
                for line in f:
                    if line.startswith("VERSION="):
                        info["nixos_version"] = line.split("=")[1].strip().strip('"')
                        break
        except:
            info["nixos_version"] = "Unknown"
        
        # Get kernel version
        try:
            info["kernel"] = os.uname().release
        except:
            info["kernel"] = "Unknown"
        
        # Get installed packages
        info["installed_packages"] = self.installed_packages
        
        return info
    
    def purge_index(self):
        """Remove the file index"""
        if INDEX_FILE.exists():
            INDEX_FILE.unlink()
            console.print("File index purged", style="success")
        
        if INDEX_DECISIONS_FILE.exists():
            INDEX_DECISIONS_FILE.unlink()
            console.print("Indexing decisions purged", style="success")
        
        self.file_index = None
        
        # Force garbage collection
        gc.collect()
    
    def send_to_mistral(self, query: str, system_prompt: str) -> Dict:
        """Send a request to the Mistral API"""
        console.print("Thinking...", style="info")
        
        url = "https://api.mistral.ai/v1/chat/completions"
        
        payload = {
            "model": self.config["model"],
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": query}
            ],
            "temperature": self.config.get("temperature", 0.2),
            "max_tokens": self.config.get("max_tokens", 2000)
        }
        
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }
        
        try:
            response = requests.post(url, json=payload, headers=headers)
            response.raise_for_status()
            
            result = response.json()
            content = result["choices"][0]["message"]["content"]
            
            # Parse the JSON response
            try:
                # Try to parse the entire response as JSON
                return json.loads(content)
            except json.JSONDecodeError:
                # Try to extract JSON part using simple heuristic
                json_start = content.find('{')
                json_end = content.rfind('}') + 1
                if json_start >= 0 and json_end > json_start:
                    json_str = content[json_start:json_end]
                    return json.loads(json_str)
                raise ValueError("Could not extract valid JSON from response")
                
        except Exception as e:
            console.print(f"API Error: {e}", style="danger")
            return {
                "commands": [],
                "explanation": f"Error communicating with Mistral API: {str(e)}"
            }
    
    def get_command_suggestions(self, query: str) -> Dict:
        """Get command suggestions from Mistral"""        
        system_prompt = self.config["system_prompt"].format(
            max_commands=self.config["max_commands"]
        )
        
        # Add system context about NixOS environment and dotfiles structure
        system_context = f"""
        The user is running NixOS with an extensive dotfiles structure containing many custom modules and 
        configurations. The dotfiles are located at {DOTFILES_PATH}.
        
        Key directories in the dotfiles:
        - modules/: Contains NixOS configuration modules
        - scripts/bash/: Contains shell scripts
        - scripts/python/: Contains Python scripts
        
        The system is built using a script that detects hardware (Razer, ASUS, VM) and applies appropriate configuration.
        Common commands may involve:
        - Nixos-rebuild: e.g., "sudo nixos-rebuild switch --flake ~/dotfiles#razer"
        - Package management: e.g., "nix search", "nix-env -i", etc.
        - Configuration editing with vim
        - Scripts like walrgb.sh for theme management
        
        The following programs are already installed on the system:
        {', '.join(self.installed_packages[:20])}
        
        When suggesting filesystem operations, be aware of this structure and suggest specific paths when possible.
        """
        
        # Add information about detected files if indexed
        if self.file_index:
            system_context += "\n\nInformation about user files:\n"
            
            # Add dotfiles structure
            if "dotfiles_structure" in self.file_index:
                system_context += "Dotfiles structure:\n"
                for dir_name, files in self.file_index["dotfiles_structure"].items():
                    system_context += f"- {dir_name}/: {', '.join(files[:10])}{' and more' if len(files) > 10 else ''}\n"
        
        system_prompt = system_prompt + system_context
        
        try:
            return self.send_to_mistral(query, system_prompt)
        except Exception as e:
            console.print(f"Error: {e}", style="danger")
            return {
                "commands": [],
                "explanation": "Failed to get suggestions. Please try again."
            }
    
    def display_commands(self, suggestions: Dict) -> Optional[str]:
        """Display command suggestions and let the user choose one"""
        if not suggestions.get("commands"):
            console.print("No command suggestions were provided.", style="danger")
            return None
        
        # Display overall explanation
        if suggestions.get("explanation"):
            console.print("\nApproach:", style="success")
            console.print(Panel(suggestions["explanation"], expand=False))
        
        # Format the command choices for console display
        console.print("\nCommand options:")
        for i, cmd in enumerate(suggestions["commands"]):
            console.print(f"{i+1}. {cmd['command']} - {cmd['description']}", style="info")
        console.print(f"{len(suggestions['commands'])+1}. None of these - try a different query")
        
        # Simple command selection
        while True:
            choice = input("\nEnter choice number: ").strip()
            try:
                choice_num = int(choice)
                if 1 <= choice_num <= len(suggestions["commands"]):
                    return suggestions["commands"][choice_num-1]["command"]
                elif choice_num == len(suggestions["commands"])+1:
                    return None
                else:
                    console.print("Invalid selection. Please try again.", style="warning")
            except ValueError:
                console.print("Please enter a number.", style="warning")
    
    def get_command_explanation(self, cmd: str, suggestions: Dict) -> str:
        """Get detailed explanation for a command"""
        for suggestion in suggestions["commands"]:
            if suggestion["command"] == cmd:
                # Use the already provided description
                description = suggestion["description"]
                
                # Generate a more detailed explanation by using the previous context
                detailed = f"Command: {cmd}\n\nWhat it does:\n{description}\n\nCommand breakdown:\n"
                
                # Simple breakdown of command parts
                parts = cmd.split()
                if len(parts) > 1:
                    for i, part in enumerate(parts):
                        if i == 0:
                            detailed += f"- {part}: The main command/program\n"
                        elif part.startswith("-"):
                            detailed += f"- {part}: An option/flag\n"
                        else:
                            detailed += f"- {part}: An argument/parameter\n"
                
                # Safety warnings for potentially dangerous commands
                danger_keywords = ["rm", "sudo rm", "mkfs", "dd", "chmod", "chown", "echo >", ">", "nixos-rebuild"]
                if any(keyword in cmd for keyword in danger_keywords):
                    detailed += "\n⚠️ Safety note: This command could modify system files or settings. Make sure you understand what it does before executing."
                
                return detailed
                
        return "No detailed explanation available for this command."
    
    def execute_command(self, cmd: str) -> Tuple[int, str, str]:
        """Execute a shell command and return exit code, stdout, and stderr"""
        console.print(f"\nExecuting: {cmd}")
        
        process = subprocess.Popen(
            cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        stdout, stderr = process.communicate()
        return process.returncode, stdout, stderr
    
    def main_loop(self):
        """Main interaction loop"""
        console.print(Panel.fit(
            "NixLLM - Mistral-powered shell assistant for NixOS",
            title="Welcome",
            style="success"
        ))
        
        # Index home directory on first run
        if not self.file_index:
            self.index_home_directory()
        
        while True:
            # Get query from user
            try:
                query = input("\n[nixllm] What would you like to do? (Ctrl+D to quit): ")
            except (KeyboardInterrupt, EOFError):
                console.print("\nGoodbye!", style="success")
                break
                
            if not query.strip():
                continue
            
            # Special commands
            if query.lower() == "reindex":
                self.index_home_directory(force_reindex=True)
                continue
            
            if query.lower() == "purge":
                self.purge_index()
                continue
                
            # Get command suggestions from Mistral
            suggestions = self.get_command_suggestions(query)
            
            # Display commands and let user choose
            selected_cmd = self.display_commands(suggestions)
            if not selected_cmd:
                console.print("No command selected. Try a different query.", style="warning")
                continue
            
            # Show explanation and ask for confirmation
            explanation = self.get_command_explanation(selected_cmd, suggestions)
            console.print("\n" + explanation)
            
            # Simple confirmation prompt
            confirmation = input(f"\nDo you want to execute: {selected_cmd}? (y/n): ").strip().lower()
            should_execute = confirmation in ('y', 'yes')
            
            if not should_execute:
                console.print("Command execution cancelled.", style="warning")
                continue
            
            # Execute the command
            exit_code, stdout, stderr = self.execute_command(selected_cmd)
            
            # Display results
            if stdout:
                console.print("\nOutput:")
                console.print(stdout)
            
            if stderr:
                console.print("\nError output:", style="danger")
                console.print(stderr)
            
            console.print(f"\nExit code: {exit_code}", 
                          style="success" if exit_code == 0 else "danger")
            
            # Add to history
            self.add_to_history(query, selected_cmd)
            
            # Release memory
            gc.collect()

def parse_args():
    parser = argparse.ArgumentParser(description="NixLLM - Mistral-powered shell assistant for NixOS")
    parser.add_argument("--config", action="store_true", help="Edit configuration")
    parser.add_argument("--setup", action="store_true", help="Run first-time setup")
    parser.add_argument("--reindex", action="store_true", help="Reindex home directory")
    parser.add_argument("--update", action="store_true", help="Update index (only new/changed files)")
    parser.add_argument("--purge", action="store_true", help="Purge all index data")
    return parser.parse_args()

def edit_config():
    """Open the config file in the default editor"""
    editor = os.environ.get("EDITOR", "vim")
    subprocess.run([editor, str(CONFIG_FILE)])

def setup_wizard():
    """Run first-time setup wizard"""
    console.print(Panel.fit(
        "Welcome to NixLLM setup wizard",
        title="Setup",
        style="success"
    ))
    
    console.print("This wizard will help you configure NixLLM.")
    
    if not CONFIG_DIR.exists():
        CONFIG_DIR.mkdir(parents=True)
    
    config = DEFAULT_CONFIG.copy()
    
    # Ask for API key and save to separate file
    api_key = input("Enter your Mistral API key: ").strip()
    if api_key:
        with open(API_KEY_FILE, 'w') as f:
            f.write(api_key)
        # Set restricted permissions (read/write only for the owner)
        API_KEY_FILE.chmod(0o600)
        console.print(f"API key saved to {API_KEY_FILE} with restricted permissions", style="success")
    
    # Ask for model
    models = ["mistral-medium", "mistral-large-latest", "mistral-small-latest"]
    console.print("Available models:")
    for i, model in enumerate(models):
        console.print(f"{i+1}. {model}")
    
    model_choice = input(f"Choose a model (1-{len(models)}, default=1): ").strip()
    try:
        model_idx = int(model_choice) - 1
        if 0 <= model_idx < len(models):
            config["model"] = models[model_idx]
    except (ValueError, IndexError):
        pass  # Keep default
    
    # Ask for temperature
    temp = input(f"Temperature (0.0-1.0, default={config['temperature']}): ").strip()
    try:
        temp_val = float(temp)
        if 0.0 <= temp_val <= 1.0:
            config["temperature"] = temp_val
    except (ValueError, IndexError):
        pass  # Keep default
    
    # Ask for file size limits
    file_size = input(f"Maximum file size to index in MB (default={config['index_max_file_size_mb']}): ").strip()
    try:
        file_size_val = float(file_size)
        if file_size_val > 0:
            config["index_max_file_size_mb"] = file_size_val
    except (ValueError, IndexError):
        pass  # Keep default
    
    dir_size = input(f"Maximum directory size to index without confirmation in MB (default={config['index_max_dir_size_mb']}): ").strip()
    try:
        dir_size_val = float(dir_size)
        if dir_size_val > 0:
            config["index_max_dir_size_mb"] = dir_size_val
    except (ValueError, IndexError):
        pass  # Keep default
    
    # Save config (without API key)
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)
    
    console.print(f"Configuration saved to {CONFIG_FILE}", style="success")
    console.print("Setup complete! You can now run nixllm to get started.")

def main():
    args = parse_args()
    
    if args.setup:
        setup_wizard()
        return
        
    if args.config:
        edit_config()
        return
    
    app = NixLLM()
    
    if args.purge:
        app.purge_index()
        return
    
    if args.reindex:
        app.index_home_directory(force_reindex=True)
        return
    
    if args.update:
        app.index_home_directory(update_only=True)
        return
    
    app.main_loop()

if __name__ == "__main__":
    main()
