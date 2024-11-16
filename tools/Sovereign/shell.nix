{ pkgs ? import <nixpkgs> {}, shellOverride ? null }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    (python3.withPackages(ps: with ps; [
    paramiko
    prompt-toolkit
    cryptography
    requests
    dnspython
    aiohttp
    tqdm
    ]))
    
    openssl
  ];

  shellHook = ''

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
