#!/usr/bin/env bash

cat > shell.nix << "NIXEOF"
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
buildInputs = with pkgs; [
python3
python3Packages.pip
python3Packages.virtualenv
fish
];

shellHook = ''
if [ ! -d "venv" ]; then
echo "Creating Python virtual environment..."
python3 -m venv venv
fi

echo "Activating virtual environment..."
source venv/bin/activate

if [ -f "requirements.txt" ]; then
echo "Installing requirements..."
pip install -r requirements.txt
fi

export VIRTUAL_ENV_DISABLE_PROMPT=1

exec fish
'';
}
NIXEOF

echo "shell.nix created! Run nix-shell to enter."
nix-shell
