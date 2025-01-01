# proxychains.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.customPrograms.proxychains;
  
  defaultConfig = {
    proxyList = [
      {
        type = "socks5";
        host = "127.0.0.1";
        port = 9050;
      }
    ];
    timeouts = {
      tcp_read = 15000;
      tcp_connect = 8000;
    };
  };

in {
  options.customPrograms.proxychains = {
    enable = mkEnableOption "proxychains-ng";
    
    package = mkOption {
      type = types.package;
      default = pkgs.proxychains-ng;
      description = "The proxychains-ng package to use.";
    };

    chain_type = mkOption {
      type = types.enum [ "strict" "dynamic" "random" ];
      default = "strict";
      description = ''
        Chain type:
        - strict: Proxies are used in the order listed (if one fails, all fail)
        - dynamic: Dead proxies are skipped
        - random: Random proxy is chosen for each connection
      '';
    };

    proxyDNS = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to proxy DNS requests";
    };

    quiet_mode = mkOption {
      type = types.bool;
      default = false;
      description = "Suppress proxy chain messages";
    };

    proxyList = mkOption {
      type = types.listOf (types.submodule {
        options = {
          type = mkOption {
            type = types.enum [ "http" "socks4" "socks5" ];
            description = "Type of proxy";
          };
          host = mkOption {
            type = types.str;
            description = "Proxy host address";
          };
          port = mkOption {
            type = types.port;
            description = "Proxy port number";
          };
          user = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Optional username for authentication";
          };
          pass = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Optional password for authentication";
          };
        };
      });
      default = defaultConfig.proxyList;
      description = "List of proxy configurations";
    };

    timeouts = mkOption {
      type = types.submodule {
        options = {
          tcp_read = mkOption {
            type = types.int;
            default = defaultConfig.timeouts.tcp_read;
            description = "TCP read timeout in milliseconds";
          };
          tcp_connect = mkOption {
            type = types.int;
            default = defaultConfig.timeouts.tcp_connect;
            description = "TCP connect timeout in milliseconds";
          };
        };
      };
      default = defaultConfig.timeouts;
      description = "Timeout configurations";
    };

    localnet = mkOption {
      type = types.listOf types.str;
      default = [ "127.0.0.0/255.0.0.0" "::1/128" ];
      description = "Networks that shouldn't be proxied";
    };
  };

  config = mkMerge [
    # Default configuration
    {
      customPrograms.proxychains = {
        enable = true;
        chain_type = "dynamic";
        quiet_mode = true;
        proxyList = [
          {
            type = "socks5";
            host = "127.0.0.1";
            port = 9050;
          }
        ];
      };
    }

    # Module implementation
    (mkIf cfg.enable {
      environment.systemPackages = [ cfg.package ];

      # Create a single global proxychains configuration
      environment.etc."proxychains/proxychains.conf".text = ''
        # Global proxychains configuration
        ${cfg.chain_type}_chain
        ${optionalString cfg.quiet_mode "quiet_mode"}
        ${optionalString cfg.proxyDNS "proxy_dns"}
        remote_dns_subnet 224

        # Timeouts
        tcp_read_time_out ${toString cfg.timeouts.tcp_read}
        tcp_connect_time_out ${toString cfg.timeouts.tcp_connect}

        # Localnet configuration
        ${concatMapStrings (net: "localnet ${net}\n") cfg.localnet}

        [ProxyList]
        ${concatMapStrings (proxy: 
          "${proxy.type} ${proxy.host} ${toString proxy.port} ${optionalString (proxy.user != null) proxy.user} ${optionalString (proxy.pass != null) proxy.pass}\n"
        ) cfg.proxyList}
      '';

      # Add fish functions and aliases
      programs.fish.interactiveShellInit = ''
        # Set proxychains config path
        set -gx PROXYCHAINS_CONF_FILE /etc/proxychains/proxychains.conf

        # Helper function to toggle proxychains
        function proxy
            switch $argv[1]
                case on
                    set -gx PROXYCHAINS_CONF_FILE /etc/proxychains/proxychains.conf
                    echo "Proxychains enabled"
                case off
                    set -e PROXYCHAINS_CONF_FILE
                    echo "Proxychains disabled"
                case status
                    if set -q PROXYCHAINS_CONF_FILE
                        echo "Proxychains is enabled"
                        echo "Config: $PROXYCHAINS_CONF_FILE"
                    else
                        echo "Proxychains is disabled"
                    end
                case '*'
                    echo "Usage: proxy [on|off|status]"
            end
        end
      '';

      programs.fish.shellAliases = {
        px = "proxychains4";
      };

      # Create the directory for proxychains config
      system.activationScripts.proxychains = ''
        mkdir -p /etc/proxychains
      '';
    })
  ];
}
