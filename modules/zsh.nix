{ config, pkgs, ... }:

{
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;

  # Enable starship
  programs.starship = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # Enable autosuggestions and syntax highlighting
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # System-wide packages needed for zsh configuration
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
  ];
}
