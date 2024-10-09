{ pkgs ? import <nixpkgs> {}, shellOverride ? null }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages(ps: with ps; [
      prompt-toolkit
      python-nmap
      pylint
      # Add any other Python packages you need here
    ]))
    nmap  # Include the nmap package itself
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
