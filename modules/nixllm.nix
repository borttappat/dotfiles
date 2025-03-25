{ config, pkgs, lib, ... }:

let
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
    anthropic
    prompt-toolkit
    rich
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
