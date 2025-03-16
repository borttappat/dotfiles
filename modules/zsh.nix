{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
  
  users.defaultUserShell = pkgs.zsh;
  
  environment.systemPackages = with pkgs; [
    starship
    zoxide
    eza
    bat
    ranger
    joshuto
    cbonsai
    glances
    pipes-rs
    bandwhich
    fastfetch
    ugrep
    figlet
    openrgb
    pywal
    # other tools referenced in the aliases
  ];
}
