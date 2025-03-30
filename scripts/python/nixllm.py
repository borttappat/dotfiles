#!/usr/bin/env python3

import os
import sys
import json
import argparse
import subprocess
import time
import gc
import sqlite3
import shutil
import readline
import psutil
from pathlib import Path
from typing import List, Dict, Optional, Tuple, Set, Any, Union
from datetime import datetime

try:
    import requests
    from rich.console import Console
    from rich.panel import Panel
    from rich.markdown import Markdown
    from rich.syntax import Syntax
    from rich.theme import Theme
    from rich.prompt import Prompt, Confirm
    from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TimeElapsedColumn
    from rich.table import Table
except ImportError:
    print("Missing required packages. Please install: requests, rich")
    sys.exit(1)

# Define custom theme to ensure formatting works correctly
custom_theme = Theme({
    "info": "cyan",
    "warning": "yellow",
    "danger": "bold red",
    "success": "bold green",
    "command": "bold blue",
    "path": "magenta",
    "highlight": "bold yellow",
})

# Initialize rich console with appropriate settings
console = Console(theme=custom_theme, highlight=True)

# Constants
CONFIG_DIR = Path.home() / ".config" / "nixllm"
DATA_DIR = Path.home() / ".local" / "share" / "nixllm"
CONFIG_FILE = CONFIG_DIR / "config.json"
API_KEY_FILE = CONFIG_DIR / "api_key"
HISTORY_DB = DATA_DIR / "history.sqlite"
INDEX_DB = DATA_DIR / "file_index.sqlite"
INDEX_DECISIONS_FILE = CONFIG_DIR / "index_decisions.json"
SESSION_ID = datetime.now().strftime("%Y%m%d%H%M%S")
MAX_HISTORY_ENTRIES = 100
DOTFILES_PATH = Path.home() / "dotfiles"
MAX_OUTPUT_STORAGE = 100 * 1024  # 100KB

# Create necessary directories
CONFIG_DIR.mkdir(parents=True, exist_ok=True)
DATA_DIR.mkdir(parents=True, exist_ok=True)

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

class HistoryManager:
    """Manages command history using SQLite"""
    def __init__(self):
        self.conn = self._create_connection()
        self.setup_database()
        
    def _create_connection(self):
        try:
            return sqlite3.connect(str(HISTORY_DB))
        except sqlite3.Error as e:
            console.print(f"Database error: {e}", style="danger")
            sys.exit(1)
    
    def setup_database(self):
        cursor = self.conn.cursor()
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS history (
            id INTEGER PRIMARY KEY,
            session_id TEXT,
            timestamp INTEGER,
            query TEXT,
            command TEXT,
            output TEXT,
            exit_code INTEGER DEFAULT NULL
        )
        ''')
        self.conn.commit()
    
    def add_entry(self, session_id: str, query: str, command: str, output: str = None, exit_code: int = None):
        # Truncate output if too large
        if output and len(output) > MAX_OUTPUT_STORAGE:
            output = output[:MAX_OUTPUT_STORAGE] + f"\n... [Output truncated, full size: {len(output)} bytes]"
            
        cursor = self.conn.cursor()
        cursor.execute('''
        INSERT INTO history (session_id, timestamp, query, command, output, exit_code)
        VALUES (?, ?, ?, ?, ?, ?)
        ''', (session_id, int(time.time()), query, command, output, exit_code))
        self.conn.commit()
        return cursor.lastrowid
    
    def get_session_history(self, session_id: str, limit: int = None):
        cursor = self.conn.cursor()
        if limit:
            cursor.execute('''
            SELECT id, timestamp, query, command, output, exit_code 
            FROM history 
            WHERE session_id = ? 
            ORDER BY timestamp DESC
            LIMIT ?
            ''', (session_id, limit))
        else:
            cursor.execute('''
            SELECT id, timestamp, query, command, output, exit_code 
            FROM history 
            WHERE session_id = ? 
            ORDER BY timestamp DESC
            ''', (session_id,))
        return cursor.fetchall()
    
    def get_entry_by_id(self, entry_id: int):
        cursor = self.conn.cursor()
        cursor.execute('SELECT query, command, output, exit_code FROM history WHERE id = ?', (entry_id,))
        return cursor.fetchone()
    
    def close(self):
        if self.conn:
            self.conn.close()

class FileIndexer:
    """Manages file indexing using SQLite"""
    def __init__(self, config: Dict):
        self.config = config
        self.conn = self._create_connection()
        self.setup_database()
        self.index_decisions = self.load_indexing_decisions()
        
    def _create_connection(self):
        try:
            return sqlite3.connect(str(INDEX_DB))
        except sqlite3.Error as e:
            console.print(f"Database error: {e}", style="danger")
            sys.exit(1)
    
    def setup_database(self):
        cursor = self.conn.cursor()
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS files (
            id INTEGER PRIMARY KEY,
            path TEXT UNIQUE,
            rel_path TEXT,
            size INTEGER,
            modified INTEGER,
            indexed_at INTEGER,
            preview TEXT
        )
        ''')
        
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS system_info (
            key TEXT PRIMARY KEY,
            value TEXT
        )
        ''')
        
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS dotfiles_structure (
            directory TEXT PRIMARY KEY,
            files TEXT
        )
        ''')
        
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_path ON files(path)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_rel_path ON files(rel_path)')
        self.conn.commit()
    
    def load_indexing_decisions(self) -> Dict:
        """Load saved user decisions about what to index"""
        if INDEX_DECISIONS_FILE.exists():
            try:
                with open(INDEX_DECISIONS_FILE, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                return {}
        return {}
    
    def save_indexing_decisions(self):
        """Save user decisions about what to index"""
        with open(INDEX_DECISIONS_FILE, 'w') as f:
            json.dump(self.index_decisions, f, indent=2)
    
    def should_index_path(self, path: Path, size_threshold: int = None) -> bool:
        """Check if a path should be indexed based on its size and user decisions"""
        path_str = str(path)
        
        # Check if we already have a decision for this path
        if path_str in self.index_decisions:
            return self.index_decisions[path_str]
            
        # Check parent directories for decisions
        for parent in path.parents:
            parent_str = str(parent)
            if parent_str in self.index_decisions:
                return self.index_decisions[parent_str]
        
        # Set size threshold based on file/directory type if not provided
        if size_threshold is None:
            if path.is_dir():
                size_threshold = self.config.get("index_max_dir_size_mb", 10) * 1024 * 1024
            else:
                size_threshold = self.config.get("index_max_file_size_mb", 2) * 1024 * 1024
        
        # Check directory size
        if path.is_dir():
            # Estimate size by checking the first level only
            try:
                size = sum(f.stat().st_size for f in path.glob('*') if f.is_file())
                if size > size_threshold:
                    console.print(f"Large directory detected: [path]{path}[/path] ({size/1024/1024:.1f} MB)", style="warning")
                    choice = Prompt.ask(
                        "Index this directory?", 
                        choices=["yes", "no", "always", "never"], 
                        default="no"
                    )
                    is_permanent = choice in ("always", "never")
                    should_index = choice in ("yes", "always")
                    
                    if is_permanent:
                        self.index_decisions[path_str] = should_index
                        self.save_indexing_decisions()
                        
                    return should_index
            except (OSError, PermissionError):
                return False
        
        # Check file size
        elif path.is_file():
            try:
                size = path.stat().st_size
                if size > size_threshold:
                    console.print(f"Large file detected: [path]{path}[/path] ({size/1024/1024:.1f} MB)", style="warning")
                    choice = Prompt.ask(
                        "Index this file?", 
                        choices=["yes", "no", "always", "never"], 
                        default="no"
                    )
                    is_permanent = choice in ("always", "never")
                    should_index = choice in ("yes", "always")
                    
                    if is_permanent:
                        self.index_decisions[path_str] = should_index
                        self.save_indexing_decisions()
                        
                    return should_index
            except (OSError, PermissionError):
                return False
        
        return True
    
    def index_file(self, file_path: Path, home_dir: Path) -> bool:
        """Index a single file"""
        try:
            if not file_path.is_file():
                return False
                
            # Skip symlinks
            if file_path.is_symlink():
                return False
            
            # Get file stats
            try:
                stats = file_path.stat()
            except (OSError, PermissionError):
                return False
            
            # Get file size and modification time
            size = stats.st_size
            mtime = int(stats.st_mtime)
            
            # Calculate relative path if inside home directory
            try:
                rel_path = str(file_path.relative_to(home_dir))
            except ValueError:
                rel_path = str(file_path)
            
            # Check if file already exists in database and is up to date
            cursor = self.conn.cursor()
            cursor.execute(
                "SELECT modified FROM files WHERE path = ?", 
                (str(file_path),)
            )
            result = cursor.fetchone()
            
            if result and result[0] >= mtime:
                # File already indexed and up to date
                return True
            
            # Check if we should index this file
            max_file_size = self.config.get("index_max_file_size_mb", 2) * 1024 * 1024
            if size > max_file_size and not self.should_index_path(file_path):
                return False
            
            # Read file preview
            preview = ""
            try:
                # Only read text files
                if file_path.suffix.lower() in {'.txt', '.md', '.py', '.sh', '.nix', '.toml', '.yaml', '.yml', '.json', '.ini', '.conf'}:
                    with open(file_path, 'r', errors='ignore') as f:
                        preview = f.read(2000)  # First 2000 chars
            except (UnicodeDecodeError, IsADirectoryError, PermissionError, OSError):
                preview = f"[Binary or unreadable file, size: {size} bytes]"
            
            # Store file info
            cursor = self.conn.cursor()
            
            if result:
                # Update existing record
                cursor.execute(
                    "UPDATE files SET size = ?, modified = ?, indexed_at = ?, preview = ?, rel_path = ? WHERE path = ?",
                    (size, mtime, int(time.time()), preview, rel_path, str(file_path))
                )
            else:
                # Insert new record
                cursor.execute(
                    "INSERT INTO files (path, rel_path, size, modified, indexed_at, preview) VALUES (?, ?, ?, ?, ?, ?)",
                    (str(file_path), rel_path, size, mtime, int(time.time()), preview)
                )
                
            self.conn.commit()
            return True
            
        except Exception as e:
            console.print(f"Error indexing {file_path}: {e}", style="danger")
            return False
    
    def index_directory(self, directory: Union[str, Path], force_reindex: bool = False, update_only: bool = False):
        """Index files in a directory"""
        directory_path = Path(directory).expanduser()
        home_dir = Path.home()
        
        if not directory_path.exists() or not directory_path.is_dir():
            console.print(f"Directory not found or not accessible: {directory_path}", style="danger")
            return False
        
        # Check if we should index this directory
        if not self.should_index_path(directory_path):
            console.print(f"Skipping directory based on user preference: {directory_path}", style="info")
            return False
        
        # Define filters
        ignored_dirs = {".git", "node_modules", "__pycache__", ".venv", "venv", ".cache", "seclists"}
        ignored_exts = {".pyc", ".pyo", ".o", ".so", ".dll", ".exe", ".bin", ".dat", ".bak", ".tmp", ".swp"}
        
        # Statistics for user feedback
        stats = {
            "files_checked": 0,
            "files_indexed": 0,
            "files_skipped": 0,
            "dirs_skipped": 0,
            "total_files": 0
        }
        
        # Count files first to provide progress information
        if not update_only:
            with Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                console=console
            ) as progress:
                task = progress.add_task("[cyan]Counting files...", total=None)
                
                for root, dirs, files in os.walk(directory_path, topdown=True):
                    # Skip ignored directories
                    dirs[:] = [d for d in dirs if d not in ignored_dirs and not d.startswith('.')]
                    stats["total_files"] += len(files)
                    
                    # Update progress periodically
                    if stats["total_files"] % 1000 == 0:
                        progress.update(task, description=f"Counted {stats['total_files']} files...")
        
        # Process files with progress bar
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            BarColumn(),
            TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
            TimeElapsedColumn(),
            console=console
        ) as progress:
            task = progress.add_task(
                f"[cyan]Indexing {directory_path}...", 
                total=stats["total_files"] if stats["total_files"] > 0 else None
            )
            
            for root, dirs, files in os.walk(directory_path, topdown=True):
                # Skip ignored directories
                dirs[:] = [d for d in dirs if d not in ignored_dirs and not d.startswith('.')]
                
                # Check if we should process this subdirectory
                root_path = Path(root)
                if not self.should_index_path(root_path):
                    dirs[:] = []  # Skip all subdirectories
                    stats["dirs_skipped"] += 1
                    continue
                
                for file in files:
                    stats["files_checked"] += 1
                    
                    # Update progress
                    if stats["total_files"] > 0:
                        progress.update(
                            task, 
                            completed=stats["files_checked"],
                            description=f"Processed {stats['files_checked']}/{stats['total_files']} files..."
                        )
                    else:
                        progress.update(
                            task, 
                            description=f"Processed {stats['files_checked']} files..."
                        )
                    
                    # Skip files based on extension
                    if any(file.endswith(ext) for ext in ignored_exts) or file.startswith('.'):
                        stats["files_skipped"] += 1
                        continue
                    
                    # Process the file
                    file_path = Path(root) / file
                    if self.index_file(file_path, home_dir):
                        stats["files_indexed"] += 1
                    else:
                        stats["files_skipped"] += 1
                    
                    # Perform garbage collection periodically
                    if stats["files_checked"] % 100 == 0:
                        gc.collect()
        
        # Update system information
        self.update_system_info()
        
        # Update dotfiles structure if it exists
        if DOTFILES_PATH.exists():
            self.update_dotfiles_structure()
        
        console.print(f"Indexed {stats['files_indexed']} files, skipped {stats['files_skipped']} files and {stats['dirs_skipped']} directories", style="success")
        return True
    
    def update_system_info(self):
        """Update system information in the database"""
        cursor = self.conn.cursor()
        
        # Clear existing info
        cursor.execute("DELETE FROM system_info")
        
        # Get NixOS version
        try:
            with open("/etc/os-release", "r") as f:
                for line in f:
                    if line.startswith("VERSION="):
                        version = line.split("=")[1].strip().strip('"')
                        cursor.execute(
                            "INSERT INTO system_info (key, value) VALUES (?, ?)",
                            ("nixos_version", version)
                        )
                        break
        except:
            pass
        
        # Get kernel version
        try:
            kernel = os.uname().release
            cursor.execute(
                "INSERT INTO system_info (key, value) VALUES (?, ?)",
                ("kernel", kernel)
            )
        except:
            pass
        
        # Add current time
        cursor.execute(
            "INSERT INTO system_info (key, value) VALUES (?, ?)",
            ("indexed_at", str(int(time.time())))
        )
        
        self.conn.commit()
    
    def update_dotfiles_structure(self):
        """Update dotfiles structure information"""
        cursor = self.conn.cursor()
        
        # Clear existing structure
        cursor.execute("DELETE FROM dotfiles_structure")
        
        # Add information about dotfiles directories
        for dir_path in ["modules", "scripts/bash", "scripts/python"]:
            full_path = DOTFILES_PATH / dir_path
            if full_path.exists() and full_path.is_dir():
                files = [f.name for f in full_path.glob("*") if f.is_file()]
                if files:
                    cursor.execute(
                        "INSERT INTO dotfiles_structure (directory, files) VALUES (?, ?)",
                        (dir_path, json.dumps(files))
                    )
        
        self.conn.commit()
    
    def search_files(self, query: str, limit: int = 5) -> List[Tuple]:
        """Search for files matching a query"""
        cursor = self.conn.cursor()
        
        # Use LIKE for simple text search
        search_term = f"%{query}%"
        
        cursor.execute('''
        SELECT path, preview FROM files 
        WHERE path LIKE ? OR preview LIKE ? 
        ORDER BY indexed_at DESC 
        LIMIT ?
        ''', (search_term, search_term, limit))
        
        return cursor.fetchall()
    
    def get_system_info(self) -> Dict:
        """Get system information from the database"""
        cursor = self.conn.cursor()
        cursor.execute("SELECT key, value FROM system_info")
        
        info = {}
        for key, value in cursor.fetchall():
            info[key] = value
            
        return info
    
    def get_dotfiles_structure(self) -> Dict:
        """Get dotfiles structure from the database"""
        cursor = self.conn.cursor()
        cursor.execute("SELECT directory, files FROM dotfiles_structure")
        
        structure = {}
        for directory, files_json in cursor.fetchall():
            structure[directory] = json.loads(files_json)
            
        return structure
    
    def purge_index(self):
        """Purge all index data"""
        cursor = self.conn.cursor()
        cursor.execute("DELETE FROM files")
        cursor.execute("DELETE FROM system_info")
        cursor.execute("DELETE FROM dotfiles_structure")
        self.conn.commit()
        
        # Optional: also delete the index decisions
        if INDEX_DECISIONS_FILE.exists():
            INDEX_DECISIONS_FILE.unlink()
            self.index_decisions = {}
            
        console.print("Index data purged successfully", style="success")
    
    def close(self):
        """Close the database connection"""
        if self.conn:
            self.conn.close()

class PackageManager:
    """Manages package detection and suggestions"""
    def __init__(self):
        self.installed_packages = self.get_installed_packages()
        self.common_utilities = {
            "ls", "cat", "grep", "find", "sed", "awk", "tr", "cut", 
            "sort", "uniq", "head", "tail", "wc", "chmod", "chown",
            "mkdir", "rmdir", "rm", "cp", "mv", "ln", "touch", "df",
            "du", "free", "ps", "kill", "top", "echo", "which", "curl",
            "wget", "ssh", "scp", "rsync", "tar", "gzip", "zip", "unzip",
            "feh", "vim", "nano", "git", "mkfs", "mount", "umount", "ifconfig"
        }
    
    def get_installed_packages(self) -> Set[str]:
        """Get a comprehensive list of installed packages"""
        packages = set()
        
        # Try nix-env for user packages
        try:
            result = subprocess.run(['nix-env', '-q'], capture_output=True, text=True, check=False)
            if result.returncode == 0:
                packages.update(p.strip() for p in result.stdout.strip().splitlines() if p.strip())
        except:
            pass
        
        # Try querying NixOS system packages
        try:
            result = subprocess.run(['nixos-option', 'environment.systemPackages'], 
                                    capture_output=True, text=True, check=False)
            if result.returncode == 0:
                # Extract package names from the complex output
                for line in result.stdout.splitlines():
                    line = line.strip()
                    if not line or '=' in line:
                        continue
                    # Try to get the package name (last part after dot)
                    parts = line.split('.')
                    if parts:
                        package = parts[-1].strip()
                        if package:
                            packages.add(package)
        except:
            pass
        
        # Check common executables in PATH
        for cmd in self.common_utilities:
            try:
                result = subprocess.run(['which', cmd], capture_output=True, text=True, check=False)
                if result.returncode == 0:
                    packages.add(cmd)
            except:
                pass
        
        return packages
    
    def is_installed(self, package: str) -> bool:
        """Check if a package is installed"""
        # Direct match
        if package in self.installed_packages:
            return True
            
        # Check for package-* format
        for pkg in self.installed_packages:
            if pkg.startswith(f"{package}-"):
                return True
                
        # Check for common utilities that are likely part of the system
        if package in self.common_utilities:
            # Do an additional check with 'which'
            try:
                result = subprocess.run(['which', package], capture_output=True, text=True, check=False)
                return result.returncode == 0
            except:
                pass
                
        return False
    
    def suggest_install_command(self, package: str) -> str:
        """Suggest how to install a package"""
        if self.is_installed(package):
            return f"# {package} is already installed"
            
        # Provide different options for installation
        return f"""# To install {package} temporarily:
nix-env -iA nixos.{package}

# To install {package} permanently, add to configuration.nix:
environment.systemPackages = with pkgs; [
  {package}
];
# Then run: sudo nixos-rebuild switch"""

class NixLLM:
    def __init__(self):
        self.config = self.load_config()
        self.api_key = self.load_api_key()
        self.history_manager = HistoryManager()
        self.indexer = None  # Initialize later to avoid unnecessary DB connection
        self.package_manager = PackageManager()
        self.session_id = SESSION_ID
        self.current_context = {}  # Store the current query context
    
    def load_config(self) -> Dict:
        """Load configuration file or create a default one if not exists"""
        if not CONFIG_DIR.exists():
            CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        
        if not CONFIG_FILE.exists():
            with open(CONFIG_FILE, 'w') as f:
                json.dump(DEFAULT_CONFIG, f, indent=2)
            console.print(f"Created default configuration at {CONFIG_FILE}", style="info")
        
        try:
            with open(CONFIG_FILE, 'r') as f:
                config = json.load(f)
                
            # Apply defaults for any missing keys
            for key, value in DEFAULT_CONFIG.items():
                if key not in config:
                    config[key] = value
                    
            return config
        except json.JSONDecodeError:
            console.print(f"Error reading config file, using defaults", style="warning")
            return DEFAULT_CONFIG
    
    def save_config(self):
        """Save configuration to file"""
        with open(CONFIG_FILE, 'w') as f:
            json.dump(self.config, f, indent=2)
    
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
    
    def lazy_init_indexer(self):
        """Initialize the indexer only when needed"""
        if self.indexer is None:
            self.indexer = FileIndexer(self.config)
    
    def index_home_directory(self, force_reindex=False, update_only=False):
        """Initialize and run the file indexer"""
        self.lazy_init_indexer()
        home_dir = Path.home()
        return self.indexer.index_directory(home_dir, force_reindex, update_only)
    
    def purge_index(self):
        """Purge the file index"""
        self.lazy_init_indexer()
        self.indexer.purge_index()
        
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
    
    def prepare_system_context(self) -> str:
        """Prepare system context information for the LLM"""
        self.lazy_init_indexer()
        
        context_parts = []
        
        # Add basic system information
        context_parts.append("""
        The user is running NixOS with an extensive dotfiles structure containing many custom modules and 
        configurations. The dotfiles are located at {0}.
        
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
        """.format(DOTFILES_PATH))
        
        # Add installed packages information
        packages_info = """
        The following programs are already installed on the system:
        {0}
        """.format(', '.join(sorted(list(self.package_manager.installed_packages))[:30]))
        context_parts.append(packages_info)
        
        # Add dotfiles structure if available
        if self.indexer:
            dotfiles_structure = self.indexer.get_dotfiles_structure()
            if dotfiles_structure:
                structure_info = "Dotfiles structure:\n"
                for dir_name, files in dotfiles_structure.items():
                    files_list = ', '.join(files[:10])
                    if len(files) > 10:
                        files_list += ", ..."
                    structure_info += f"- {dir_name}/: {files_list}\n"
                context_parts.append(structure_info)
        
        # Add system info
        if self.indexer:
            system_info = self.indexer.get_system_info()
            if system_info:
                sys_info_text = "System information:\n"
                for key, value in system_info.items():
                    if key != "indexed_at":  # Skip indexing timestamp
                        sys_info_text += f"- {key}: {value}\n"
                context_parts.append(sys_info_text)
        
        return "\n\n".join(context_parts)
    
    def get_command_suggestions(self, query: str) -> Dict:
        """Get command suggestions from Mistral"""
        # Format the system prompt
        system_prompt = self.config["system_prompt"].format(
            max_commands=self.config["max_commands"]
        )
        
        # Add system context
        system_context = self.prepare_system_context()
        if system_context:
            system_prompt += "\n\n" + system_context
        
        # Remember the context for future reference
        self.current_context = {
            "query": query,
            "system_prompt": system_prompt
        }
        
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
        
        # Create a table for the command options
        table = Table(title="Command Options")
        table.add_column("Option", style="cyan")
        table.add_column("Command", style="green")
        table.add_column("Description", style="yellow")
        
        # Add each command to the table
        for i, cmd in enumerate(suggestions["commands"]):
            table.add_row(
                f"{i+1}", 
                cmd['command'],
                cmd['description']
            )
        
        # Add the "none of these" option
        table.add_row(
            f"{len(suggestions['commands'])+1}",
            "None of these",
            "Try a different query"
        )
        
        console.print(table)
        
        # Command selection
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
        # Find the matching command in suggestions
        description = ""
        for suggestion in suggestions["commands"]:
            if suggestion["command"] == cmd:
                description = suggestion["description"]
                break
        
        # Generate a more detailed breakdown
        parts = cmd.split()
        breakdown = []
        
        if parts:
            # Explain the main command
            main_cmd = parts[0]
            breakdown.append(f"- {main_cmd}: The main command/program")
            
            # Check if it's installed
            if not self.package_manager.is_installed(main_cmd):
                breakdown.append(f"  Note: This command ({main_cmd}) may not be installed on your system.")
            
            # Explain options and arguments
            for i, part in enumerate(parts[1:], 1):
                if part.startswith('-'):
                    breakdown.append(f"- {part}: Option/flag")
                else:
                    breakdown.append(f"- {part}: Argument/parameter")
        
        # Check for potential dangers
        danger_keywords = {
            "rm": "This command removes files/directories",
            "dd": "This command can overwrite disk data",
            "mkfs": "This command creates a filesystem (formatting)",
            "chmod": "This command changes file permissions",
            "chown": "This command changes file ownership",
            "sudo rm": "This command forcefully removes files as root",
            "mv /": "This command moves files from/to the root directory",
            "rm -rf": "This command forcefully removes directories recursively",
            ">": "This command redirects output, potentially overwriting files",
            "nixos-rebuild": "This command rebuilds your system configuration"
        }
        
        warnings = []
        for keyword, warning in danger_keywords.items():
            if keyword in cmd:
                warnings.append(f"- Warning: {warning}")
        
        # Format the final explanation
        explanation = f"""## Command: `{cmd}`

### Description
{description}

### Command breakdown
{"".join(f"{part}\n" for part in breakdown)}

{"### ⚠️ Safety warnings\n" + "".join(f"{warning}\n" for warning in warnings) if warnings else ""}
"""
        
        return explanation
    
    def execute_command(self, cmd: str) -> Tuple[int, str, str]:
        """Execute a shell command and return exit code, stdout, and stderr"""
        console.print(f"\nExecuting: [command]{cmd}[/command]")
        
        process = subprocess.Popen(
            cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,  # Line buffered
            universal_newlines=True
        )
        
        stdout_lines = []
        stderr_lines = []
        
        # Real-time output streaming
        while True:
            # Process stdout
            stdout_line = process.stdout.readline()
            if stdout_line:
                console.print(stdout_line, end='')
                stdout_lines.append(stdout_line)
            
            # Process stderr
            stderr_line = process.stderr.readline()
            if stderr_line:
                console.print(stderr_line, style="danger", end='')
                stderr_lines.append(stderr_line)
            
            # Check if process is still running
            if process.poll() is not None:
                # Get any remaining output
                remaining_stdout, remaining_stderr = process.communicate()
                
                if remaining_stdout:
                    console.print(remaining_stdout, end='')
                    stdout_lines.append(remaining_stdout)
                
                if remaining_stderr:
                    console.print(remaining_stderr, style="danger", end='')
                    stderr_lines.append(remaining_stderr)
                
                break
        
        # Combine all output
        stdout = ''.join(stdout_lines)
        stderr = ''.join(stderr_lines)
        
        return process.returncode, stdout, stderr
    
    def process_special_command(self, cmd: str) -> bool:
        """Process special internal commands"""
        cmd_lower = cmd.strip().lower()
        
        # Handle simple built-in commands
        if cmd_lower == "history":
            self.show_history()
            return True
            
        if cmd_lower == "help":
            self.show_help()
            return True
            
        if cmd_lower.startswith("rerun "):
            self.rerun_command(cmd_lower[6:].strip())
            return True
            
        if cmd_lower == "index":
            self.index_home_directory(update_only=True)
            return True
            
        if cmd_lower == "reindex":
            self.index_home_directory(force_reindex=True)
            return True
            
        if cmd_lower == "purge":
            self.purge_index()
            return True
            
        if cmd_lower.startswith("explain "):
            self.explain_command(cmd[8:].strip())
            return True
            
        if cmd_lower.startswith("config "):
            self.handle_config(cmd[7:])
            return True
            
        # Not a special command
        return False
    
    def show_history(self):
        """Show command history for the current session"""
        history = self.history_manager.get_session_history(self.session_id)
        
        if not history:
            console.print("No commands in history for this session", style="info")
            return
        
        # Create a table for the history
        table = Table(title=f"Command History for Session {self.session_id}")
        table.add_column("ID", style="cyan")
        table.add_column("Time", style="magenta")
        table.add_column("Query", style="yellow")
        table.add_column("Command", style="green")
        table.add_column("Status", style="cyan")
        
        # Add each history entry to the table
        for id, timestamp, query, command, _, exit_code in history:
            # Format the timestamp
            time_str = datetime.fromtimestamp(timestamp).strftime("%H:%M:%S")
            
            # Format the status based on exit code
            status = "✓" if exit_code == 0 else "✗" if exit_code is not None else "?"
            status_style = "success" if exit_code == 0 else "danger" if exit_code is not None else ""
            
            table.add_row(
                str(id),
                time_str,
                query[:30] + "..." if len(query) > 30 else query,
                command[:40] + "..." if len(command) > 40 else command,
                f"[{status_style}]{status}[/{status_style}]" if status_style else status
            )
        
        console.print(table)
    
    def rerun_command(self, id_str: str):
        """Re-run a command from history by ID"""
        try:
            entry_id = int(id_str)
            entry = self.history_manager.get_entry_by_id(entry_id)
            
            if not entry:
                console.print(f"No command found with ID {entry_id}", style="danger")
                return
            
            query, command, _, _ = entry
            
            console.print(f"Re-running command from history:")
            console.print(f"Original query: [highlight]{query}[/highlight]")
            console.print(f"Command: [command]{command}[/command]")
            
            if not Confirm.ask("Execute this command?", default=True):
                console.print("Command execution cancelled", style="warning")
                return
            
            # Execute the command
            exit_code, stdout, stderr = self.execute_command(command)
            
            # Display the result
            if stdout:
                console.print("Output:", style="info")
                console.print(stdout)
            
            if stderr:
                console.print("Error output:", style="danger")
                console.print(stderr)
            
            console.print(f"Exit code: {exit_code}", 
                          style="success" if exit_code == 0 else "danger")
            
            # Add to history (as a re-run)
            self.history_manager.add_entry(
                self.session_id, 
                f"rerun {id_str}: {query}", 
                command, 
                stdout + stderr, 
                exit_code
            )
            
        except ValueError:
            console.print("Please provide a valid command ID", style="danger")
    
    def explain_command(self, command: str):
        """Explain a command without executing it"""
        if not command:
            console.print("Please provide a command to explain", style="danger")
            return
        
        # Prepare the prompt for command explanation
        prompt = f"""Explain the following shell command in detail:
```
{command}
```

Break it down step by step. Explain each part of the command, including all options and arguments.
Also mention any potential safety concerns or side effects.
"""
        
        console.print(f"Analyzing command: [command]{command}[/command]", style="info")
        
        # Get explanation from Mistral
        explanation = self.send_to_mistral(prompt, """
        You are a Linux command expert specializing in NixOS.
        When asked to explain a command, provide:
        1. A general explanation of what the command does
        2. A breakdown of each command component
        3. An explanation of each flag and argument
        4. Any potential risks or side effects
        5. Common use cases or variations
        
        Format your response in Markdown.
        """)
        
        if isinstance(explanation, dict) and "explanation" in explanation:
            # If we got back our standard format, use the explanation field
            console.print(Panel(Markdown(explanation["explanation"]), title="Command Explanation", border_style="cyan"))
        elif isinstance(explanation, dict) and "content" in explanation:
            # Alternative format that might come back
            console.print(Panel(Markdown(explanation["content"]), title="Command Explanation", border_style="cyan"))
        else:
            # Fallback to showing the raw response
            console.print(Panel(str(explanation), title="Command Explanation", border_style="cyan"))
    
    def handle_config(self, args: str):
        """Handle configuration commands"""
        parts = args.split(maxsplit=1)
        
        if not parts:
            # Show current config
            table = Table(title="Current Configuration")
            table.add_column("Setting", style="cyan")
            table.add_column("Value", style="yellow")
            
            for key, value in self.config.items():
                if key == "system_prompt":
                    # Truncate long system prompt
                    display_value = value[:50] + "..." if len(str(value)) > 50 else value
                elif key == "api_key":
                    # Mask API key
                    display_value = "********"
                else:
                    display_value = str(value)
                    
                table.add_row(key, display_value)
                
            console.print(table)
            return
        
        if len(parts) == 1:
            # Show a specific config value
            key = parts[0]
            if key in self.config:
                if key == "system_prompt":
                    # Show full system prompt
                    console.print(f"{key}:", style="info")
                    console.print(Panel(self.config[key], border_style="cyan"))
                else:
                    console.print(f"{key}: {self.config[key]}", style="info")
            else:
                console.print(f"Config key '{key}' not found", style="danger")
            return
        
        # Set a config value
        key, value = parts
        if key not in self.config:
            console.print(f"Unknown config key: {key}", style="danger")
            return
        
        # Handle different value types
        try:
            if key in ("temperature", "index_max_file_size_mb", "index_max_dir_size_mb"):
                self.config[key] = float(value)
            elif key in ("max_commands", "max_tokens"):
                self.config[key] = int(value)
            elif key in ("safe_mode"):
                self.config[key] = value.lower() in ("true", "yes", "1", "on")
            else:
                self.config[key] = value
                
            self.save_config()
            console.print(f"Updated {key} to {value}", style="success")
            
        except ValueError:
            console.print(f"Invalid value for {key}: {value}", style="danger")
    
    def show_help(self):
        """Show help information"""
        help_text = """
NixLLM Command Assistant for NixOS

Built-in Commands:
  help                      Show this help message
  history                   Show command history for the current session
  rerun <id>                Re-run a command by its history ID
  index                     Update the file index (only new/changed files)
  reindex                   Force a complete reindex of the home directory
  purge                     Purge all indexed data
  explain <command>         Explain a command without executing it
  config [key] [value]      View or set configuration values

Usage:
  - Type your question in natural language
  - Select a command from the suggestions
  - Confirm execution when prompted

Examples:
  "How do I update my system packages?"
  "Find large files in my home directory"
  "How can I restart the network service?"
"""
        console.print(Panel(help_text, title="NixLLM Help", border_style="cyan"))
    
    def show_memory_usage(self):
        """Show current memory usage"""
        process = psutil.Process(os.getpid())
        memory_info = process.memory_info()
        
        console.print(f"Memory usage: {memory_info.rss / (1024 * 1024):.2f} MB", style="info")
    
    def main_loop(self):
        """Main interaction loop"""
        console.print(Panel.fit(
            "NixLLM - Mistral-powered shell assistant for NixOS",
            title="Welcome",
            style="success"
        ))
        
        console.print("Type 'help' for available commands or 'exit' to quit.", style="info")
        
        # Initialize indexer on first run
        self.lazy_init_indexer()
        
        # Check if we need to index
        cursor = self.indexer.conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM files")
        file_count = cursor.fetchone()[0]
        
        if file_count == 0:
            if Confirm.ask("No indexed files found. Index your home directory now?", default=True):
                self.index_home_directory()
        
        while True:
            # Get query from user
            try:
                query = input("\n[nixllm]> ")
            except (KeyboardInterrupt, EOFError):
                console.print("\nGoodbye!", style="success")
                break
                
            query = query.strip()
            if not query:
                continue
                
            # Check for exit command
            if query.lower() in ("exit", "quit", "q"):
                console.print("Goodbye!", style="success")
                break
            
            # Check for special internal commands
            if self.process_special_command(query):
                continue
            
            # Get command suggestions from Mistral
            suggestions = self.get_command_suggestions(query)
            
            if not suggestions or not suggestions.get("commands"):
                console.print("No command suggestions available. Please try a different query.", style="warning")
                continue
            
            # Display commands and let user choose
            selected_cmd = self.display_commands(suggestions)
            if not selected_cmd:
                console.print("No command selected. Try a different query.", style="warning")
                continue
            
            # Show explanation and ask for confirmation
            explanation = self.get_command_explanation(selected_cmd, suggestions)
            console.print(Panel(Markdown(explanation), title="Command Explanation", border_style="blue"))
            
            # Check for potentially dangerous operations
            is_dangerous = any(kw in selected_cmd for kw in ["rm -", "sudo rm", "mkfs", "dd", "> /etc", "chmod -"])
            
            # Simple confirmation prompt
            if is_dangerous:
                console.print("⚠️ This command might be destructive or have system-wide effects!", style="danger")
                should_execute = Confirm.ask("Do you want to execute this command?", default=False)
            else:
                should_execute = Confirm.ask("Execute this command?", default=True)
            
            if not should_execute:
                console.print("Command execution cancelled.", style="warning")
                continue
            
            # Execute the command
            exit_code, stdout, stderr = self.execute_command(selected_cmd)
            
            # Add to history
            self.history_manager.add_entry(
                self.session_id, 
                query, 
                selected_cmd, 
                stdout + stderr, 
                exit_code
            )
            
            # Release memory
            gc.collect()

def parse_args():
    parser = argparse.ArgumentParser(description="NixLLM - Mistral-powered shell assistant for NixOS")
    parser.add_argument("--config", action="store_true", help="Edit configuration")
    parser.add_argument("--setup", action="store_true", help="Run first-time setup")
    parser.add_argument("--reindex", action="store_true", help="Reindex home directory")
    parser.add_argument("--update", action="store_true", help="Update index (only new/changed files)")
    parser.add_argument("--purge", action="store_true", help="Purge all index data")
    parser.add_argument("--explain", metavar="COMMAND", help="Explain a command without executing it")
    parser.add_argument("--memory", action="store_true", help="Show memory usage")
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
    
    # Create directory for database files
    DATA_DIR.mkdir(parents=True, exist_ok=True)

def main():
    args = parse_args()
    
    if args.setup:
        setup_wizard()
        return
        
    if args.config:
        edit_config()
        return
    
    app = NixLLM()
    
    if args.memory:
        app.show_memory_usage()
        return
    
    if args.purge:
        app.purge_index()
        return
    
    if args.reindex:
        app.index_home_directory(force_reindex=True)
        return
    
    if args.update:
        app.index_home_directory(update_only=True)
        return
    
    if args.explain:
        app.explain_command(args.explain)
        return
    
    app.main_loop()

if __name__ == "__main__":
    main()
