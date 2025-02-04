#!/usr/bin/env python3
import os
import sys
import json
import time
import signal
import argparse
import subprocess
import configparser
import requests
from pathlib import Path
from typing import Optional, Dict, Any, Generator
import readline  # For better input handling with arrow keys
import socket

class OllamaConnectionError(Exception):
    """Raised when Ollama service is not available"""
    pass

class ModelNotFoundError(Exception):
    """Raised when a local model is not found in Ollama"""
    pass

class ConfigManager:
    """Manages Nixi configuration including API keys and preferences"""
    def __init__(self):
        self.config_dir = Path.home() / '.config' / 'nixi'
        self.config_file = self.config_dir / 'config.ini'
        self.ensure_config_exists()
        self.load_config()

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

    def load_config(self):
        """Load the configuration"""
        self.config = configparser.ConfigParser()
        self.config.read(self.config_file)

    def get_config(self) -> configparser.ConfigParser:
        """Return the current configuration"""
        return self.config

    def update_config(self, section: str, key: str, value: str):
        """Update a specific configuration value"""
        if not self.config.has_section(section):
            self.config.add_section(section)
        self.config[section][key] = value
        with open(self.config_file, 'w') as f:
            self.config.write(f)

class AIProvider:
    """Base class for AI providers"""
    def query(self, prompt: str, **kwargs) -> Generator[str, None, None]:
        raise NotImplementedError

    def check_availability(self) -> bool:
        raise NotImplementedError

class OllamaProvider(AIProvider):
    """Provider for local Ollama models"""
    def __init__(self, model_name: str = "mistral"):
        self.model_name = model_name
        self.base_url = "http://localhost:11434"

    def check_availability(self) -> bool:
        """Check if Ollama is running and the model is available"""
        try:
            # First check if Ollama service is running
            response = requests.get(f"{self.base_url}/api/version")
            if response.status_code != 200:
                raise OllamaConnectionError("Ollama service is not responding")

            # Then check if the specified model is available
            response = requests.get(f"{self.base_url}/api/tags")
            if response.status_code != 200:
                raise OllamaConnectionError("Cannot fetch model information from Ollama")

            available_models = [model['name'] for model in response.json()['models']]
            if self.model_name not in available_models:
                raise ModelNotFoundError(f"Model '{self.model_name}' not found. Available models: {', '.join(available_models)}")

            return True
        except requests.exceptions.ConnectionError:
            raise OllamaConnectionError("Cannot connect to Ollama service. Is it running?")

    def query(self, prompt: str, **kwargs) -> Generator[str, None, None]:
        """Stream responses from Ollama"""
        try:
            print("Sending request to Ollama...", flush=True)
            response = requests.post(
                f"{self.base_url}/api/generate",
                json={
                    "model": self.model_name,
                    "prompt": prompt,
                    "stream": True
                },
                stream=True
            )
            
            if response.status_code != 200:
                error_msg = f"\nError: Ollama returned status code {response.status_code}"
                if response.status_code == 404:
                    error_msg += f"\nModel '{self.model_name}' not found. Try running: ollama pull {self.model_name}"
                yield error_msg
                return

            for line in response.iter_lines():
                if line:
                    try:
                        json_response = json.loads(line)
                        if 'response' in json_response:
                            yield json_response['response']
                        elif 'error' in json_response:
                            yield f"\nOllama error: {json_response['error']}"
                    except json.JSONDecodeError as e:
                        print(f"\nError decoding JSON: {line}", file=sys.stderr)
                        continue
        except requests.exceptions.ConnectionError:
            yield "\nError: Cannot connect to Ollama. Is it running? Try: systemctl start ollama"
        except Exception as e:
            yield f"\nError communicating with Ollama: {str(e)}"
            print(f"\nDetailed error: {str(e)}", file=sys.stderr)

class MistralProvider(AIProvider):
    """Provider for Mistral API"""
    def __init__(self, api_key: str, model_name: str = "mistral-tiny"):
        self.api_key = api_key
        self.model_name = model_name
        self.api_url = "https://api.mistral.ai/v1/chat/completions"

    def check_availability(self) -> bool:
        """Check if API key is valid and model is available"""
        try:
            response = requests.post(
                self.api_url,
                headers={"Authorization": f"Bearer {self.api_key}"},
                json={
                    "model": self.model_name,
                    "messages": [{"role": "user", "content": "test"}],
                    "max_tokens": 1
                }
            )
            response.raise_for_status()
            return True
        except requests.exceptions.RequestException as e:
            raise Exception(f"Mistral API error: {str(e)}")

    def query(self, prompt: str, **kwargs) -> Generator[str, None, None]:
        """Stream responses from Mistral API"""
        try:
            response = requests.post(
                self.api_url,
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": self.model_name,
                    "messages": [{"role": "user", "content": prompt}],
                    "stream": True
                },
                stream=True
            )
            
            for line in response.iter_lines():
                if line:
                    try:
                        json_response = json.loads(line.decode('utf-8').split('data: ')[1])
                        if 'choices' in json_response and json_response['choices']:
                            content = json_response['choices'][0]['delta'].get('content', '')
                            if content:
                                yield content
                    except:
                        continue
        except Exception as e:
            yield f"\nError with Mistral API: {str(e)}"

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
Last modified: {time.ctime(stats.st_mtime)}
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
            files = [f for f in os.listdir(dir_path) if os.path.isfile(os.path.join(dir_path, f))]
            file_contents = {}
            for file in files[:5]:  # Limit to first 5 files to avoid overload
                file_path = os.path.join(dir_path, file)
                try:
                    with open(file_path, 'r') as f:
                        file_contents[file] = f.read()[:1000]  # First 1000 characters
                except:
                    continue
            
            context = f"Directory {dir_path} contents:\n{dir_contents.stdout}\n\n"
            context += "Sample of file contents:\n"
            for file, content in file_contents.items():
                context += f"\n--- {file} ---\n{content}\n"
            return context
        except Exception as e:
            return f"Error reading directory {dir_path}: {str(e)}"

def print_streaming(generator: Generator[str, None, None]):
    """Print streaming text with proper handling of line endings"""
    for chunk in generator:
        print(chunk, end='', flush=True)
    print()  # New line at the end

class Nixi:
    """Main Nixi application class"""
    def __init__(self):
        self.config_manager = ConfigManager()
        self.config = self.config_manager.get_config()
        self.setup_provider()
        self.conversation_history = []

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
                     dir_path: Optional[str] = None) -> Generator[str, None, None]:
        """Process a query with optional file or directory context"""
        try:
            # Check provider availability
            self.provider.check_availability()
            
            context = ""
            if file_path:
                context = FileContextManager.get_file_context(file_path)
            elif dir_path:
                context = FileContextManager.get_dir_context(dir_path)
            
            full_prompt = f"Context:\n{context}\n\nQuery: {query}" if context else query
            
            # Add to conversation history
            self.conversation_history.append({"role": "user", "content": full_prompt})
            
            return self.provider.query(
                full_prompt,
                temperature=float(self.config['Settings'].get('temperature', 0.7))
            )
        except (OllamaConnectionError, ModelNotFoundError) as e:
            yield f"\nError: {str(e)}"
            if isinstance(e, ModelNotFoundError):
                yield "\nTo install the model, run: ollama pull mistral"
        except Exception as e:
            yield f"\nError: {str(e)}"

def interactive_mode(nixi: Nixi):
    """Run nixi in interactive mode"""
    print("\033[1;32mWelcome to nixi interactive mode!\033[0m")
    print("Commands:")
    print("  \033[1mhelp\033[0m     - Show this help message")
    print("  \033[1mexit\033[0m     - Exit interactive mode")
    print("  \033[1m-f FILE\033[0m  - Analyze a file")
    print("  \033[1m-d DIR\033[0m   - Analyze a directory")
    print("\nUsing model: \033[1;34m{}\033[0m".format(
        nixi.config['API'].get('default_model', 'local:mistral')
    ))
    
    # Check Ollama availability at startup if using local model
    if nixi.config['API'].get('default_model', '').startswith('local:'):
        try:
            nixi.provider.check_availability()
            print("\033[1;32m✓\033[0m Ollama service is running")
        except OllamaConnectionError:
            print("\033[1;31m✗\033[0m Ollama service is not running")
            print("  Try: systemctl start ollama")
        except ModelNotFoundError as e:
            print("\033[1;33m!\033[0m Model not found: {}".format(str(e)))
            print("  Try: ollama pull {}".format(
                nixi.config['API'].get('default_model', '').split(':')[1]
            ))
    
    try:
        while True:
            try:
                query = input("\n\033[1;36mnixi>\033[0m ").strip()
                
                if not query:
                    continue
                
                if query.lower() == 'exit':
                    print("\nGoodbye!")
                    break
                elif query.lower() == 'help':
                    print("\nAvailable commands:")
                    print("  \033[1mhelp\033[0m     - Show this help message")
                    print("  \033[1mexit\033[0m     - Exit interactive mode")
                    print("  \033[1m-f FILE\033[0m  - Analyze a file")
                    print("  \033[1m-d DIR\033[0m   - Analyze a directory")
                    print("  \033[1m-m MODEL\033[0m - Switch model (e.g., -m local:mistral)")
                    continue
                
                # Parse simple commands
                file_path = None
                dir_path = None
                
                words = query.split()
                if len(words) >= 2 and words[0] == '-f':
                    file_path = words[1]
                    query = ' '.join(words[2:])
                elif len(words) >= 2 and words[0] == '-d':
                    dir_path = words[1]
                    query = ' '.join(words[2:])
                
                print_streaming(nixi.process_query(query, file_path, dir_path))
                
            except KeyboardInterrupt:
                print("\nUse 'exit' to quit or continue with a new query.")
                continue
            
    except Exception as e:
        print(f"\nError in interactive mode: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description='Nixi - NixOS AI Assistant')
    parser.add_argument('--query', '-q', help='Query for the AI')
    parser.add_argument('--file', '-f', help='File to analyze')
    parser.add_argument('--dir', '-d', help='Directory to analyze')
    parser.add_argument('--config', '-c', action='store_true', 
                       help='Configure nixi settings')
    parser.add_argument('--interactive', '-i', action='store_true',
                       help='Run in interactive mode')
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

        if args.interactive:
            interactive_mode(nixi)
        elif args.query:
            print_streaming(nixi.process_query(args.query, args.file, args.dir))
        else:
            print("Please provide a query using --query/-q or use --interactive/-i mode")
            
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
