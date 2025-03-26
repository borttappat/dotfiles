#!/usr/bin/env python3

import os
import sys
import json
import argparse
import subprocess
import time
from pathlib import Path
from typing import List, Dict, Optional, Tuple

try:
    import requests
    from rich.console import Console
    from rich.panel import Panel
    from rich.markdown import Markdown
except ImportError:
    print("Missing required packages. Please install: requests, rich")
    sys.exit(1)

# Initialize rich console
console = Console()

# Constants
CONFIG_DIR = Path.home() / ".config" / "nixllm"
CONFIG_FILE = CONFIG_DIR / "config.json"
API_KEY_FILE = CONFIG_DIR / "api_key"
HISTORY_FILE = CONFIG_DIR / "history.json"
MAX_HISTORY_ENTRIES = 100
DOTFILES_PATH = Path.home() / "dotfiles"

# Default configuration
DEFAULT_CONFIG = {
    "model": "mistral-medium",
    "max_commands": 5,
    "safe_mode": True,
    "max_tokens": 2000,
    "temperature": 0.2,
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
    """
}

class NixLLM:
    def __init__(self):
        self.config = self.load_config()
        self.api_key = self.load_api_key()
        self.history = self.load_history()
        
        # Add home directory indexing capabilities
        self.file_index = None
    
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
            console.print(f"API key file not found at {API_KEY_FILE}", style="bold red")
            console.print("Please run with --setup to configure your API key.")
            sys.exit(1)
        
        with open(API_KEY_FILE, 'r') as f:
            api_key = f.read().strip()
            
        if not api_key:
            console.print("API key is empty.", style="bold red")
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
    
    def index_home_directory(self):
        """Index files in the user's home directory for reference"""
        console.print("Indexing home directory...", style="bold yellow")
        
        index = {"files": {}}
        ignored_dirs = {".git", "node_modules", "__pycache__", ".venv", "venv", ".cache", "seclists"}
        ignored_exts = {".pyc", ".pyo", ".o", ".so", ".dll", ".exe", ".bin", ".dat", ".bak", ".tmp", ".swp"}
        max_file_size = 1024 * 1024  # 1 MB
        
        home_dir = Path.home()
        for root, dirs, files in os.walk(home_dir, topdown=True, followlinks=False):  # Don't follow symlinks
            # Skip ignored directories
            dirs[:] = [d for d in dirs if d not in ignored_dirs]
            
            for file in files:
                try:
                    file_path = Path(root) / file
                    
                    # Skip symlinks to avoid loops
                    if file_path.is_symlink():
                        continue
                    
                    # Skip binary files and those too large
                    try:
                        if (file_path.suffix in ignored_exts or 
                                file_path.stat().st_size > max_file_size):
                            continue
                    except (FileNotFoundError, PermissionError, OSError):
                        continue
                    
                    # Skip hidden files and directories
                    if file.startswith('.') or any(part.startswith('.') for part in file_path.parts):
                        continue
                        
                    try:
                        # Store file information
                        rel_path = str(file_path.relative_to(home_dir))
                        abs_path = str(file_path)
                        
                        # Read a sample of the file for better context
                        content_preview = ""
                        try:
                            with open(file_path, 'r', errors='ignore') as f:
                                content_preview = f.read(1000)  # First 1000 chars
                        except (UnicodeDecodeError, IsADirectoryError, PermissionError, OSError):
                            continue  # Skip binary files
                        
                        index["files"][rel_path] = {
                            "path": abs_path,
                            "modified": file_path.stat().st_mtime,
                            "size": file_path.stat().st_size,
                            "preview": content_preview
                        }
                        
                    except Exception as e:
                        # Skip any problematic files
                        continue
                except Exception as e:
                    # Skip any file that causes errors
                    continue
        
        # Save extra info about dotfiles structure if it exists
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
        
        self.file_index = index
        console.print(f"Indexed {len(index['files'])} files in home directory", style="green")
        
        return index
    
    def send_to_mistral(self, query: str, system_prompt: str) -> Dict:
        """Send a request to the Mistral API"""
        console.print("Thinking...", style="bold yellow")
        
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
            console.print(f"API Error: {e}", style="bold red")
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
            console.print(f"Error: {e}", style="bold red")
            return {
                "commands": [],
                "explanation": "Failed to get suggestions. Please try again."
            }
    
    def display_commands(self, suggestions: Dict) -> Optional[str]:
        """Display command suggestions and let the user choose one"""
        if not suggestions.get("commands"):
            console.print("No command suggestions were provided.", style="bold red")
            return None
        
        # Display overall explanation
        if suggestions.get("explanation"):
            console.print("\n[bold green]Approach:[/bold green]")
            console.print(Panel(suggestions["explanation"], expand=False))
        
        # Format the command choices for console display
        console.print("\n[bold]Command options:[/bold]")
        for i, cmd in enumerate(suggestions["commands"]):
            console.print(f"{i+1}. [cyan]{cmd['command']}[/cyan] - {cmd['description']}")
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
                    console.print("Invalid selection. Please try again.", style="yellow")
            except ValueError:
                console.print("Please enter a number.", style="yellow")
    
    def get_command_explanation(self, cmd: str, suggestions: Dict) -> str:
        """Get detailed explanation for a command"""
        for suggestion in suggestions["commands"]:
            if suggestion["command"] == cmd:
                # Use the already provided description
                description = suggestion["description"]
                
                # Generate a more detailed explanation by using the previous context
                detailed = f"""
                [bold]Command:[/bold] {cmd}
                
                [bold]What it does:[/bold]
                {description}
                
                [bold]Command breakdown:[/bold]
                """
                
                # Simple breakdown of command parts
                parts = cmd.split()
                if len(parts) > 1:
                    detailed += "\n"
                    for i, part in enumerate(parts):
                        if i == 0:
                            detailed += f"- [cyan]{part}[/cyan]: The main command/program\n"
                        elif part.startswith("-"):
                            detailed += f"- [yellow]{part}[/yellow]: An option/flag\n"
                        else:
                            detailed += f"- [green]{part}[/green]: An argument/parameter\n"
                
                # Safety warnings for potentially dangerous commands
                danger_keywords = ["rm", "sudo rm", "mkfs", "dd", "chmod", "chown", "echo >", ">", "nixos-rebuild"]
                if any(keyword in cmd for keyword in danger_keywords):
                    detailed += "\n[bold red]⚠️ Safety note:[/bold red] This command could modify system files or settings. Make sure you understand what it does before executing."
                
                return detailed
                
        return "No detailed explanation available for this command."
    
    def execute_command(self, cmd: str) -> Tuple[int, str, str]:
        """Execute a shell command and return exit code, stdout, and stderr"""
        console.print(f"\n[bold]Executing:[/bold] {cmd}")
        
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
            "[bold]NixLLM[/bold] - Mistral-powered shell assistant for NixOS",
            title="Welcome",
            border_style="green"
        ))
        
        # Index home directory on first run
        if not self.file_index:
            self.index_home_directory()
        
        while True:
            # Get query from user
            try:
                console.print("\n[nixllm] What would you like to do? (Ctrl+D to quit): ", end="")
                query = input()
            except (KeyboardInterrupt, EOFError):
                console.print("\nGoodbye!", style="bold green")
                break
                
            if not query.strip():
                continue
            
            # Special commands
            if query.lower() == "reindex":
                self.index_home_directory()
                continue
                
            # Get command suggestions from Mistral
            suggestions = self.get_command_suggestions(query)
            
            # Display commands and let user choose
            selected_cmd = self.display_commands(suggestions)
            if not selected_cmd:
                console.print("No command selected. Try a different query.", style="yellow")
                continue
            
            # Show explanation and ask for confirmation
            explanation = self.get_command_explanation(selected_cmd, suggestions)
            console.print(Markdown(explanation))
            
            # Simple confirmation prompt
            console.print(f"\nDo you want to execute: [bold cyan]{selected_cmd}[/bold cyan]? (y/n): ", end="")
            confirmation = input().strip().lower()
            should_execute = confirmation in ('y', 'yes')
            
            if not should_execute:
                console.print("Command execution cancelled.", style="yellow")
                continue
            
            # Execute the command
            exit_code, stdout, stderr = self.execute_command(selected_cmd)
            
            # Display results
            if stdout:
                console.print("\n[bold]Output:[/bold]")
                console.print(stdout)
            
            if stderr:
                console.print("\n[bold red]Error output:[/bold red]")
                console.print(stderr, style="red")
            
            console.print(f"\n[bold]Exit code:[/bold] {exit_code}", 
                          style="green" if exit_code == 0 else "red")
            
            # Add to history
            self.add_to_history(query, selected_cmd)

def parse_args():
    parser = argparse.ArgumentParser(description="NixLLM - Mistral-powered shell assistant for NixOS")
    parser.add_argument("--config", action="store_true", help="Edit configuration")
    parser.add_argument("--setup", action="store_true", help="Run first-time setup")
    parser.add_argument("--reindex", action="store_true", help="Reindex home directory")
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
        border_style="green"
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
        console.print(f"API key saved to {API_KEY_FILE} with restricted permissions", style="green")
    
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
    
    # Save config (without API key)
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)
    
    console.print(f"Configuration saved to {CONFIG_FILE}", style="green")
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
    
    if args.reindex:
        app.index_home_directory()
        return
    
    app.main_loop()

if __name__ == "__main__":
    main()
