{ pkgs ? import <nixpkgs> {}, shellOverride ? null }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages(ps: with ps; [
      python-nmap
      paramiko
      prompt-toolkit

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
    if [ -n "${toString shellOverride}" ]; then
      exec ${toString shellOverride}
    elif command -v fish &> /dev/null; then
      exec fish
    else
      echo "Fish is not installed. Using default shell."
    fi
  '';
}
