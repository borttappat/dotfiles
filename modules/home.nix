{ config, pkgs, ... }:

{
  home.stateVersion = "25.05";
  home.enableNixpkgsReleaseCheck = false;
  
  programs.firefox = {
    enable = true;
    profiles."default" = {
      id = 0;
      isDefault = true;
      
      settings = {
        "font.name.monospace.x-western" = "Cozette";
        "font.name.sans-serif.x-western" = "Cozette";
        "font.name.serif.x-western" = "Cozette";
        "font.size.monospace.x-western" = 13;
        "font.size.variable.x-western" = 13;
        "font.minimum-size.x-western" = 13;
        "browser.display.use_document_fonts" = 0;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      
      userChrome = ''
        * {
          font-family: "Cozette", monospace !important;
          font-size: 13px !important;
          line-height: 13px !important;
          -webkit-font-smoothing: none !important;
          -moz-osx-font-smoothing: unset !important;
          font-smooth: never !important;
          transform: none !important;
        }

        @-moz-document url-prefix(about:), url-prefix(chrome://browser/content/) {
          * {
            font-family: "Cozette", monospace !important;
            font-size: 13px !important;
            line-height: 13px !important;
          }
        }
      '';
      
      userContent = ''
        * {
          font-family: "Cozette", monospace !important;
          font-size: 13px !important;
          line-height: 13px !important;
          -webkit-font-smoothing: none !important;
          -moz-osx-font-smoothing: unset !important;
          font-smooth: never !important;
          text-rendering: optimizeSpeed !important;
          transform: none !important;
        }

        h1, h2 {
          font-size: 26px !important;
          line-height: 26px !important;
        }
      '';
    };
  };
}
