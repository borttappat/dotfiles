#!/usr/bin/env python3
import os
import sys
import json
import argparse
import subprocess
from pathlib import Path
import configparser
import requests
from typing import Optional, Dict, Any

class ConfigManager:
    """Manages Nixi configuration including API keys and preferences"""
    def __init__(self):
        self.config_dir = Path.home() / '.config' / 'nixi'
        self.config_file = self.config_dir / 'config.ini'
        self.ensure_config_exists()

    def ensure_config_exists(self):
        """Create config directory and file if they don't exist"""
        self.config_dir.mkdir(parents=True, exist_ok=True)
        if not self.config_file.exists():
            config = configparser.ConfigParser()
            config['API'] = {
                'mistral_api_key': '',
                'default_model': 'local:mistral',
            }
            config['Settings'] = {
                'max_context_length': '4000',
                'temperature': '0.7',
            }
            with open(self.config_file, 'w') as f:
                config.write(f)

    def get_config(self) -> configparser.ConfigParser:
        """Read and return the configuration"""
        config = configparser.ConfigParser()
        config.read(self.config_file)
        return config

    def update_config(self, section: str, key: str, value: str):
        """Update a specific configuration value"""
        config = self.get_config()
        if not config.has_section(section):
            config.add_section(section)
        config[section][key] = value
        with open(self.config_file, 'w') as f:
            config.write(f)

class AIProvider:
    """Base class for AI providers"""
    def query(self, prompt: str, **kwargs) -> str:
        raise NotImplementedError

class OllamaProvider(AIProvider):
    """Provider for local Ollama models"""
    def __init__(self, model_name: str = "mistral"):
        self.model_name = model_name

    def query(self, prompt: str, **kwargs) -> str:
        cmd = ["ollama", "run", self.model_name, prompt]
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode != 0:
                raise Exception(f"Ollama error: {result.stderr}")
            return result.stdout
        except Exception as e:
            return f"Error running Ollama query: {str(e)}"

class MistralProvider(AIProvider):
    """Provider for Mistral API"""
    def __init__(self, api_key: str, model_name: str = "mistral-tiny"):
        self.api_key = api_key
        self.model_name = model_name
        self.api_url = "https://api.mistral.ai/v1/chat/completions"

    def query(self, prompt: str, **kwargs) -> str:
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        data = {
            "model": self.model_name,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": float(kwargs.get('temperature', 0.7))
        }

        try:
            response = requests.post(self.api_url, headers=headers, json=data)
            response.raise_for_status()
            return response.json()['choices'][0]['message']['content']
        except Exception as e:
            return f"Error with Mistral API: {str(e)}"

class FileContextManager:
    """Handles file and directory context gathering"""
    @staticmethod
    def get_file_context(file_path: str) -> str:
        try:
            with open(file_path, 'r') as f:
                content = f.read()
            stats = os.stat(file_path)
            return f"""
File: {file_path}
Size: {stats.st_size} bytes
Last modified: {stats.st_mtime}
Content:
{content}
"""
        except Exception as e:
            return f"Error reading {file_path}: {str(e)}"

    @staticmethod
    def get_dir_context(dir_path: str) -> str:
        try:
            dir_contents = subprocess.run(
                ["ls", "-la", dir_path], 
                capture_output=True, 
                text=True
            )
            return f"Directory {dir_path} contents:\n{dir_contents.stdout}"
        except Exception as e:
            return f"Error reading directory {dir_path}: {str(e)}"

class Nixi:
    """Main Nixi application class"""
    def __init__(self):
        self.config_manager = ConfigManager()
        self.config = self.config_manager.get_config()
        self.setup_provider()

    def setup_provider(self):
        """Set up the AI provider based on configuration"""
        model = self.config['API'].get('default_model', 'local:mistral')
        
        if model.startswith('local:'):
            self.provider = OllamaProvider(model_name=model.split(':')[1])
        else:
            api_key = self.config['API'].get('mistral_api_key')
            if not api_key:
                raise ValueError("Mistral API key not configured")
            self.provider = MistralProvider(api_key=api_key, model_name=model)

    def process_query(self, query: str, file_path: Optional[str] = None, 
                     dir_path: Optional[str] = None) -> str:
        """Process a query with optional file or directory context"""
        context = ""
        
        if file_path:
            context = FileContextManager.get_file_context(file_path)
        elif dir_path:
            context = FileContextManager.get_dir_context(dir_path)
        
        full_prompt = f"Context:\n{context}\n\nQuery: {query}" if context else query
        
        return self.provider.query(
            full_prompt,
            temperature=float(self.config['Settings'].get('temperature', 0.7))
        )

def main():
    parser = argparse.ArgumentParser(description='Nixi - NixOS AI Assistant')
    parser.add_argument('--query', '-q', help='Query for the AI')
    parser.add_argument('--file', '-f', help='File to analyze')
    parser.add_argument('--dir', '-d', help='Directory to analyze')
    parser.add_argument('--config', '-c', action='store_true', 
                       help='Configure Nixi settings')
    parser.add_argument('--model', '-m', help='Specify AI model to use')
    
    args = parser.parse_args()
    
    try:
        nixi = Nixi()
        
        if args.config:
            # Handle configuration
            api_key = input("Enter Mistral API key (press Enter to skip): ").strip()
            if api_key:
                nixi.config_manager.update_config('API', 'mistral_api_key', api_key)
            
            model = input("Enter default model (e.g., local:mistral, mistral-tiny): ").strip()
            if model:
                nixi.config_manager.update_config('API', 'default_model', model)
            
            print("Configuration updated successfully!")
            return

        if args.model:
            nixi.config_manager.update_config('API', 'default_model', args.model)
            nixi.setup_provider()

        if args.query:
            result = nixi.process_query(args.query, args.file, args.dir)
            print(result)
        else:
            print("Please provide a query using --query or -q")
            
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
