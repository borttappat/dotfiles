{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages(ps: with ps; [
      prompt-toolkit
      python-nmap
      # Add any other Python packages you need here
    ]))
    nmap  # Include the nmap package itself
  ];

  shellHook = ''
    echo "Python environment with prompt-toolkit and python-nmap is ready!"
    echo "Nmap is also available in this shell."
  '';
}
