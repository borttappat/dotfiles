{ pkgs ? import <nixpkgs> {}, shellOverride ? null }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages(ps: with ps; [
      pip
      virtualenv
    ]))
    
  ];

  shellHook = ''
    # Create and activate virtual environment
    if [ ! -d .venv ]; then
      python -m venv .venv
      source .venv/bin/activate
      
      # Install all required packages via pip
      pip install --upgrade pip
      pip install paramiko prompt-toolkit cryptography requests dnspython sublist3r
    else
      source .venv/bin/activate
    fi

    # Make sure we're using the virtual environment
    export VIRTUAL_ENV=$(pwd)/.venv
    export PATH="$VIRTUAL_ENV/bin:$PATH"

    if [ -n "${toString shellOverride}" ]; then
      exec ${toString shellOverride}
    elif command -v fish &> /dev/null; then
      exec fish
    else
      echo "Fish is not installed. Using default shell."
    fi

    echo "Virtual environment is active. All required packages should be available."
  '';
}
