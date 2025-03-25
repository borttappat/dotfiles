#!/usr/bin/env python3

import os
import sys
import json
import asyncio
import argparse
import subprocess
import textwrap
from pathlib import Path
from typing import List, Dict, Optional, Tuple

import anthropic
from prompt_toolkit import PromptSession
from prompt_toolkit.shortcuts import radiolist_dialog, yes_no_dialog
from prompt_toolkit.styles import Style
from rich.console import Console
from rich.panel import Panel
from rich.syntax import Syntax
from rich.markdown import Markdown

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
    "model": "claude-3-5-sonnet-20240229",
    "max_commands": 5,
    "safe_mode": True,
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

styles = Style.from_dict({
    'dialog': 'bg:#323232',
    'dialog.body': 'bg:#323232 #ffffff',
    'dialog.border': 'bg:#323232 #888888',
    'button': 'bg:#456ebc #ffffff',
    'button.focused': 'bg:#789efc #ffffff',
    'checkbox': 'bg:#323232 #ffffff',
    'checkbox.checked': 'bg:#323232 #ffffff',
    'checkbox.selected': 'bg:#789efc #ffffff',
})

class NixLLM:
    def __init__(self):
        self.config = self.load_config()
        self.api_key = self.load_api_key()
        self.history = self.load_history()
        self.client = anthropic.Anthropic(api_key=self.api_key)
        self.session = PromptSession()
    
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
            console.print("Please run 'nixllm --setup' to configure your API key.")
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
            
    def save_config(self):
        """Save configuration to file"""
        with open(CONFIG_FILE, 'w') as f:
            json.dump(self.config, f, indent=2)
    
    def load_history(self) -> List[Dict]:
        """Load command history from file"""
        if not HISTORY_FILE.exists():
            return []
        
        with open(HISTORY_FILE, 'r') as f:
            return json.load(f)
    
    def save_history(self):
        """Save command history to file"""
        with open(HISTORY_FILE, 'w') as f:
            json.dump(self.history[-MAX_HISTORY_ENTRIES:], f, indent=2)
    
    def add_to_history(self, query: str, command: str):
        """Add a command to history"""
        self.history.append({
            "query": query,
            "command": command,
            "timestamp": asyncio.get_event_loop().time()
        })
        self.save_history()
    
    async def get_command_suggestions(self, query: str) -> Dict:
        """Get command suggestions from Claude"""
        console.print("Thinking...", style="bold yellow")
        
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
        
        system_prompt = system_prompt + system_context
        
        try:
            response = await asyncio.to_thread(
                self.client.messages.create,
                model=self.config["model"],
                system=system_prompt,
                max_tokens=2000,
                temperature=0.2,
                messages=[{"role": "user", "content": query}],
            )
            
            # Extract JSON from the response
            try:
                content = response.content[0].text
                # Try to parse the entire response as JSON
                try:
                    return json.loads(content)
                except json.JSONDecodeError:
                    # Try to extract JSON part using simple heuristic
                    json_start = content.find('{')
                    json_end = content.rfind('}') + 1
                    if json_start >= 0 and json_end > json_start:
                        json_str = content[json_start:json_end]
                        return json.loads(json_str)
                    raise ValueError("Could not extract valid JSON from response")
                    
            except (json.JSONDecodeError, ValueError) as e:
                console.print(f"Error parsing LLM response: {e}", style="bold red")
                console.print("Raw response:", style="dim")
                console.print(response.content[0].text)
                return {
                    "commands": [],
                    "explanation": "Failed to parse response from Claude. Please try again."
                }
            
        except Exception as e:
            console.print(f"API Error: {e}", style="bold red")
            return {
                "commands": [],
                "explanation": f"Error communicating with Claude API: {str(e)}"
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
        
        # Prepare command options for the radio list
        values = [(cmd["command"], f"{cmd['command']} - {cmd['description']}") 
                 for cmd in suggestions["commands"]]
        
        # Add "None of these" option
        values.append(("none", "None of these - let me try a different query"))
        
        # Display radio list dialog
        result = radiolist_dialog(
            title="Select a command to execute",
            text="Choose one of the following commands:",
            values=values,
            style=styles
        ).run()
        
        if result == "none" or result is None:
            return None
            
        return result
    
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
    
    async def main_loop(self):
        """Main interaction loop"""
        console.print(Panel.fit(
            "[bold]NixLLM[/bold] - LLM-powered shell assistant for NixOS",
            title="Welcome",
            border_style="green"
        ))
        
        while True:
            # Get query from user
            try:
                query = self.session.prompt("\n[nixllm] What would you like to do? (Ctrl+D to quit): ")
            except (KeyboardInterrupt, EOFError):
                console.print("\nGoodbye!", style="bold green")
                break
                
            if not query.strip():
                continue
                
            # Get command suggestions from Claude
            suggestions = await self.get_command_suggestions(query)
            
            # Display commands and let user choose
            selected_cmd = self.display_commands(suggestions)
            if not selected_cmd:
                console.print("No command selected. Try a different query.", style="yellow")
                continue
            
            # Show explanation and ask for confirmation
            explanation = self.get_command_explanation(selected_cmd, suggestions)
            console.print(Markdown(explanation))
            
            should_execute = yes_no_dialog(
                title="Execute command?",
                text=f"Do you want to execute: {selected_cmd}",
                style=styles
            ).run()
            
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
    parser = argparse.ArgumentParser(description="NixLLM - LLM-powered shell assistant for NixOS")
    parser.add_argument("--config", action="store_true", help="Edit configuration")
    parser.add_argument("--setup", action="store_true", help="Run first-time setup")
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
    api_key = input("Enter your Anthropic API key: ").strip()
    if api_key:
        with open(API_KEY_FILE, 'w') as f:
            f.write(api_key)
        # Set restricted permissions (read/write only for the owner)
        API_KEY_FILE.chmod(0o600)
        console.print(f"API key saved to {API_KEY_FILE} with restricted permissions", style="green")
    
    # Ask for model
    models = ["claude-3-5-sonnet-20240229", "claude-3-opus-20240229", "claude-3-haiku-20240307"]
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
    
    # Save config (without API key)
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)
    
    console.print(f"Configuration saved to {CONFIG_FILE}", style="green")
    console.print("Setup complete! You can now run nixllm to get started.")

async def main():
    args = parse_args()
    
    if args.setup:
        setup_wizard()
        return
        
    if args.config:
        edit_config()
        return
    
    app = NixLLM()
    await app.main_loop()

if __name__ == "__main__":
    asyncio.run(main())
