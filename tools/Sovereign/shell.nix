{ pkgs ? import <nixpkgs> {}, shellOverride ? null }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages(ps: with ps; [
      python-nmap
      paramiko
      prompt-toolkit
      cryptography
      requests
      urllib3
      #sublist3r
      dnspython

      # Testing and linting
      pylint
      black
    ]))
    
    # Required system tools
    nmap
    whatweb
    exploitdb  # for searchsploit
    ffuf
  ];

  shellHook = ''

   # Create virtual environment if it doesn't exist
    if [ ! -d .venv ]; then
      python -m venv .venv
    fi

    # Activate virtual environment
    source .venv/bin/activate

    # Install Sublist3r if not already installed
    if ! python -c "import sublist3r" 2>/dev/null; then
      pip install sublist3r
    fi

    if [ -n "${toString shellOverride}" ]; then
      exec ${toString shellOverride}
    elif command -v fish &> /dev/null; then
      exec fish
    else
      echo "Fish is not installed. Using default shell."
    fi
  '';
}
