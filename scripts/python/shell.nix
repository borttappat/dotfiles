{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages(ps: with ps; [
      prompt-toolkit
      python-nmap
      pycryptodome
      # Add any other Python packages you need here
    ]))
  ];

  #shellHook = ''
  #'';
}
