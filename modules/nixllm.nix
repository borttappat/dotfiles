{ config, pkgs, lib, ... }:

let
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
    requests
    rich
    # No longer need anthropic, but we need requests instead
  ]);

  nixllm = pkgs.writeScriptBin "nixllm" ''
    #!${pythonEnv}/bin/python3
    ${builtins.readFile ../scripts/python/nixllm.py}
  '';
in {
  environment.systemPackages = [
    nixllm
    pythonEnv
  ];
}
