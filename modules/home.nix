{ config, pkgs, ... }:

{
  home.stateVersion = "22.11";
  
  programs.firefox = {
    enable = true;
    profiles."default" = {
      settings = {
        "toolkit.zoomManager.zoomValues" = "1,2,3,4,5";
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
