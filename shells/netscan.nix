# ~/dotfiles/shells/netscan.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Python and necessary packages
    (python3.withPackages (ps: with ps; [
      python-nmap
    ]))
    
    # Network tools
    nmap
    
    # Other utilities that might be useful
    jq      # For JSON processing if needed
  ];

  shellHook = ''
    echo "NixOS development environment loaded"
    echo "Python version: $(python --version)"
    echo "Nmap version: $(nmap --version | head -n 1)"
  '';
}
