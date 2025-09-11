# Security Hardening Module
# This module overrides security-related settings from other configs
# Use mkForce to override existing declarations

{ config, pkgs, lib, ... }:

{
  # SECURITY OVERRIDE: Disable auto-login (overrides users.nix)
  services.getty.autologinUser = lib.mkForce null;

  # SECURITY OVERRIDE: Require password for sudo (overrides users.nix)
  security.sudo = {
    enable = true;
    wheelNeedsPassword = lib.mkForce true;
    extraRules = lib.mkForce [
      {
        users = [ "traum" ]; # Replace with your username
        commands = [
          {
            command = "ALL";
            options = [ "SETENV" ]; # Remove NOPASSWD
          }
        ];
      }
    ];
    extraConfig = ''
      Defaults timestamp_timeout=5
      Defaults passwd_tries=3
      Defaults passwd_timeout=1
      Defaults insults
      Defaults lecture=always
      Defaults logfile="/var/log/sudo.log"
      Defaults log_input,log_output
    '';
  };

  # SECURITY OVERRIDE: Harden SSH (overrides services.nix)
  services.openssh = {
    enable = true;
    settings = lib.mkForce {
      #PasswordAuthentication = false;
      PermitRootLogin = "no";
      Protocol = 2;
      X11Forwarding = false;
      MaxAuthTries = 3;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      AllowUsers = [ "traum" ]; # Replace with your username
      Port = 22;
    };
    extraConfig = ''
      AllowAgentForwarding no
      AllowTcpForwarding no
      AllowStreamLocalForwarding no
      Banner /etc/ssh/banner
    '';
  };

  # SECURITY OVERRIDE: Strict firewall (overrides configuration.nix)
  networking.firewall = {
    enable = lib.mkForce true;
    allowedTCPPorts = lib.mkForce [ 22 ]; # Only SSH
    allowedUDPPorts = lib.mkForce [ ];
    allowPing = lib.mkForce false;
    logReversePathDrops = true;
    logRefusedConnections = true;
    logRefusedPackets = true;
    extraCommands = ''
      # Rate limit SSH connections
      iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
      iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 5 --name SSH -j DROP
      
      # Drop invalid packets
      iptables -A INPUT -m state --state INVALID -j DROP
      
      # Log dropped packets (limited to prevent log spam)
      iptables -A INPUT -m limit --limit 3/min --limit-burst 3 -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
    '';
  };

  # SECURITY ADDITION: Enable fail2ban for intrusion detection
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "192.168.0.0/16"
      "172.16.0.0/12"
    ];
    jails = {
      ssh = {
        settings = {
          enabled = true;
          port = "22";
          filter = "sshd";
          logpath = "/var/log/auth.log";
          maxretry = 3;
          bantime = 3600;
          findtime = 600;
        };
      };
      ssh-ddos = {
        settings = {
          enabled = true;
          port = "22";
          filter = "sshd-ddos";
          logpath = "/var/log/auth.log";
          maxretry = 6;
          bantime = 600;
          findtime = 120;
        };
      };
    };
  };

  # SECURITY ADDITION: Enable auditd for system monitoring
  security.auditd.enable = true;
  security.audit = {
    enable = true;
    rules = [
      # Monitor authentication events
      "-w /etc/passwd -p wa -k passwd_changes"
      "-w /etc/shadow -p wa -k shadow_changes"
      "-w /etc/group -p wa -k group_changes"
      "-w /etc/sudoers -p wa -k sudoers_changes"
      "-w /etc/sudoers.d/ -p wa -k sudoers_changes"
      
      # Monitor login/logout events
      "-w /var/log/auth.log -p wa -k auth_changes"
      "-w /var/log/lastlog -p wa -k lastlog_changes"
      
      # Monitor network configuration changes
      "-w /etc/network/ -p wa -k network_changes"
      "-w /etc/systemd/network/ -p wa -k network_changes"
      
      # Monitor system configuration changes
      "-w /etc/systemd/ -p wa -k systemd_changes"
      "-w /etc/nixos/ -p wa -k nixos_changes"
      
      # Monitor kernel module loading
      "-w /sbin/insmod -p x -k module_insertion"
      "-w /sbin/rmmod -p x -k module_removal"
      "-w /sbin/modprobe -p x -k module_insertion"
      
      # Monitor privileged commands
      "-a always,exit -F arch=b64 -S execve -F euid=0 -k privileged_commands"
      "-a always,exit -F arch=b32 -S execve -F euid=0 -k privileged_commands"
    ];
  };

  # SECURITY ADDITION: Kernel security hardening
  boot.kernel.sysctl = lib.mkMerge [
    {
      # Network security hardening
      "net.ipv4.ip_forward" = lib.mkOverride 200 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv4.conf.default.accept_source_route" = 0;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv4.conf.default.log_martians" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      
      # IPv6 security
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.default.accept_source_route" = 0;
      
      # Memory protection
      "kernel.randomize_va_space" = 2;
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
      "net.core.bpf_jit_harden" = 2;
      
      # File system security
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.suid_dumpable" = 0;
    }
  ];

  # SECURITY ADDITION: Enable AppArmor
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
    packages = with pkgs; [
      apparmor-utils
      apparmor-profiles
    ];
  };

  # SECURITY ADDITION: Restrict access to sensitive information
  security.hideProcessInformation = true;

  # SECURITY ADDITION: Secure boot parameters (merged with existing)
  boot.kernelParams = lib.mkAfter [
    "slub_debug=FZP"
    "page_poison=1"
    "vsyscall=none"
    "debugfs=off"
    "oops=panic"
    "module.sig_enforce=1"
    "lockdown=confidentiality"
    "mce=0"
    "page_alloc.shuffle=1"
    "rng_core.default_quality=500"
  ];

  # SECURITY ADDITION: Disable unnecessary and potentially dangerous kernel modules
  boot.blacklistedKernelModules = [
    # Disable uncommon network protocols
    "dccp"      # Datagram Congestion Control Protocol
    "sctp"      # Stream Control Transmission Protocol
    "rds"       # Reliable Datagram Sockets
    "tipc"      # Transparent Inter Process Communication
    "n-hdlc"    # High-level Data Link Control
    "ax25"      # Amateur X.25
    "netrom"    # NET/ROM
    "x25"       # X.25
    "rose"      # ROSE
    "decnet"    # DECnet
    "econet"    # Econet
    "af_802154" # IEEE 802.15.4
    "ipx"       # IPX
    "appletalk" # AppleTalk
    "psnap"     # SubNetwork Access Protocol
    "p8023"     # Novell raw IEEE 802.3
    "p8022"     # IEEE 802.2
    "can"       # Controller Area Network
    "atm"       # Asynchronous Transfer Mode
    
    # Disable rare filesystems
    "cramfs"    # Compressed ROM filesystem
    "freevxfs"  # Veritas filesystem
    "jffs2"     # Journalling Flash filesystem
    "hfs"       # Hierarchical filesystem
    "hfsplus"   # Extended Hierarchical filesystem
    "squashfs"  # Compressed read-only filesystem
    "udf"       # Universal Disk Format
  ];

  # SECURITY ADDITION: Disable core dumps globally
  systemd.coredump.enable = false;
  security.pam.loginLimits = [
    { domain = "*"; type = "hard"; item = "core"; value = "0"; }
    { domain = "*"; type = "soft"; item = "core"; value = "0"; }
  ];

  # SECURITY ADDITION: Password policies
  security.pam.services.passwd.text = ''
    password required pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1
  '';

  # SECURITY ADDITION: Account lockout policy
  security.pam.services.login.text = lib.mkAfter ''
    auth required pam_tally2.so deny=5 unlock_time=900 even_deny_root
  '';

  # SECURITY ADDITION: Session timeout
  environment.etc."profile.d/session-timeout.sh".text = ''
    export TMOUT=1800  # 30 minutes
    readonly TMOUT
  '';

  # SECURITY ADDITION: SSH banner
  environment.etc."ssh/banner".text = ''
    ╔══════════════════════════════════════════════════════════════════╗
    ║                            WARNING                               ║
    ║                                                                  ║
    ║ This system is for authorized users only. All activities on     ║
    ║ this system are logged and monitored. Unauthorized access is    ║
    ║ strictly prohibited and will be prosecuted to the full extent   ║
    ║ of the law.                                                      ║
    ║                                                                  ║
    ║ By continuing, you acknowledge that you have read and accept     ║
    ║ this warning.                                                    ║
    ╚══════════════════════════════════════════════════════════════════╝
  '';

  # SECURITY ADDITION: Enable automatic security updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "daily";
    flags = [ "--update-input" "nixpkgs" "--no-write-lock-file" ];
  };

  # SECURITY ADDITION: Security monitoring tools
  environment.systemPackages = with pkgs; [
    fail2ban
    aide          # Advanced Intrusion Detection Environment
    rkhunter      # Rootkit Hunter
    chkrootkit    # Check for rootkits
    lynis         # Security auditing tool
    nmap          # Network discovery and security auditing
    tcpdump       # Network packet analyzer
    wireshark-cli # Network protocol analyzer
    netstat-nat   # Network statistics
    ss            # Socket statistics
    iotop         # I/O monitoring
    htop          # Process monitoring
    auditd        # Audit daemon
    
    # Security analysis tools
    (writeShellScriptBin "security-check" ''
      #!/bin/sh
      echo "=== Security Status Check ==="
      echo "Date: $(date)"
      echo
      
      echo "=== Failed SSH Attempts (Last 24h) ==="
      journalctl -u sshd --since "24 hours ago" | grep "Failed\|Invalid" | tail -10
      
      echo -e "\n=== Sudo Usage (Last 10 entries) ==="
      tail -10 /var/log/sudo.log 2>/dev/null || echo "No sudo log found"
      
      echo -e "\n=== Open Network Ports ==="
      ss -tuln
      
      echo -e "\n=== Recent Logins ==="
      last | head -10
      
      echo -e "\n=== Fail2ban Status ==="
      fail2ban-client status 2>/dev/null || echo "Fail2ban not running"
      
      echo -e "\n=== Active Fail2ban Jails ==="
      fail2ban-client status ssh 2>/dev/null || echo "SSH jail not active"
      
      echo -e "\n=== Firewall Status ==="
      systemctl status firewall --no-pager -l | head -10
      
      echo -e "\n=== Audit Log Summary (Last 24h) ==="
      ausearch -ts recent 2>/dev/null | tail -5 || echo "No recent audit events"
      
      echo -e "\n=== System Load ==="
      uptime
      
      echo -e "\n=== Disk Usage ==="
      df -h / /home 2>/dev/null
    '')
    
    (writeShellScriptBin "security-scan" ''
      #!/bin/sh
      echo "Running comprehensive security scan..."
      echo "This may take several minutes..."
      echo
      
      echo "=== Running Lynis Security Audit ==="
      lynis audit system --quick --quiet
      
      echo -e "\n=== Running RKHunter ==="
      rkhunter --check --skip-keypress --report-warnings-only
      
      echo -e "\n=== Running chkrootkit ==="
      chkrootkit -q
      
      echo -e "\n=== Security scan complete ==="
      echo "Check /var/log/lynis.log for detailed Lynis results"
    '')
  ];

  # SECURITY ADDITION: Regular security maintenance
  systemd.services.security-maintenance = {
    description = "Daily security maintenance tasks";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      # Update RKHunter database
      ${pkgs.rkhunter}/bin/rkhunter --propupd --quiet
      
      # Rotate audit logs if they get too large
      if [ -f /var/log/audit/audit.log ] && [ $(stat -f%z /var/log/audit/audit.log) -gt 104857600 ]; then
        ${pkgs.auditd}/bin/auditctl -k
        mv /var/log/audit/audit.log /var/log/audit/audit.log.$(date +%Y%m%d)
        ${pkgs.gzip}/bin/gzip /var/log/audit/audit.log.$(date +%Y%m%d)
        systemctl restart auditd
      fi
      
      # Clean old logs
      find /var/log -name "*.log.*.gz" -mtime +30 -delete
    '';
  };

  systemd.timers.security-maintenance = {
    description = "Run security maintenance daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
