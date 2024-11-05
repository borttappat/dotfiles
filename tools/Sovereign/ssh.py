#!/usr/bin/env python3
import paramiko 
import argparse 
from pathlib import Path 
from datetime import datetime
import os
from prompt_toolkit import prompt 


def resolve_path(path):
    """Resolve relative or absolute path"""
    return str(Path(path).expanduser().resolve())


def ssh_connect(hostname, username, password=None, key_file=None, port=22):
    """Establish SSH connection using password or key-based auth"""
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        if key_file:  # Key-based auth
            key_path = resolve_path(key_file)
            if not os.path.exists(key_path):
                raise FileNotFoundError(f"Key file not found: {key_path}")
            key = paramiko.RSAKey.from_private_key_file(key_path)
            ssh.connect(hostname, port, username, pkey=key)
        else:  # Password auth
            if not password:
                password = prompt("Enter SSH password: ", is_password=True)
            ssh.connect(hostname, port, username, password)
        return ssh
    except Exception as e:
        print(f"Connection failed: {e}")
        return None


def upload_and_execute(ssh, local_file, remote_path, save_local=True, save_remote=False):
    """Upload local file to remote server and execute it"""
    try:
        # Setup file paths and SFTP
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        sftp = ssh.open_sftp()
        
        # Check and upload local file
        local_path = resolve_path(local_file)
        if not os.path.exists(local_path):
            raise FileNotFoundError(f"Script not found: {local_path}")
            
        # Upload and make executable
        remote_file = Path(remote_path) / Path(local_path).name
        sftp.put(local_path, str(remote_file))
        ssh.exec_command(f"chmod +x {remote_file}")
        
        # Setup output paths
        local_output = f"scan_{timestamp}.txt" if save_local else None
        remote_output = f"{remote_path}/scan_{timestamp}.txt" if save_remote else None
        
        # Execute and capture output
        cmd = str(remote_file)
        if remote_output:
            cmd = f"{cmd} | tee {remote_output}"
        
        stdin, stdout, stderr = ssh.exec_command(cmd)
        output = stdout.read().decode()
        errors = stderr.read().decode()
        
        # Save outputs
        if local_output:
            with open(local_output, "w") as f:
                f.write(output)
                if errors:
                    f.write("\nErrors:\n")
                    f.write(errors)
            print(f"Output saved locally to {local_output}")
        
        if remote_output:
            print(f"Output saved remotely to {remote_output}")
            
        print("Output:", output)
        if errors:
            print("Errors:", errors)
        
        sftp.close()
        return True
    except Exception as e:
        print(f"Error during file operations: {e}")
        return False


def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="SSH file transfer and execution tool")
    parser.add_argument("host", help="Target hostname")
    parser.add_argument("-u", "--username", required=True, help="SSH username")
    parser.add_argument("-s", "--script", required=True, help="Local script to upload and execute")
    parser.add_argument("-p", "--password", help="SSH password")
    parser.add_argument("-k", "--key-file", help="SSH private key file path")
    parser.add_argument("-P", "--port", type=int, default=22, help="SSH port")
    parser.add_argument("-r", "--remote-path", default="/tmp", help="Remote path for script upload")
    parser.add_argument("-n", "--no-local-save", action="store_true", help="Don't save output locally")
    parser.add_argument("-sr", "--save-remote", action="store_true", help="Save output on remote system")
    
    args = parser.parse_args()
    
    # Connect and execute
    ssh = ssh_connect(args.host, args.username, args.password, args.key_file, args.port)
    if ssh:
        try:
            if upload_and_execute(ssh, args.script, args.remote_path, 
                                not args.no_local_save, args.save_remote):
                print("Script executed successfully")
            ssh.close()
        except Exception as e:
            print(f"Error: {e}")


if __name__ == "__main__":
    main()
