# On-demand pentesting toolsets.
#
# These used to live in modules/pentesting.nix as system-wide packages, which
# bloated every build and the closure. They are now nix-develop shells, pulled
# in only when needed:
#
#   nix develop ~/dotfiles#appsec      (or the `AppSec` shell alias)
#   nix develop ~/dotfiles#netsec      (or `NetSec` - includes AD tooling)
#   nix develop ~/dotfiles#wifi
#   nix develop ~/dotfiles#forensics   (forensics, stego, reverse engineering)
#   nix develop ~/dotfiles#osint
#   nix develop ~/dotfiles#cracking
#
# Only evergreen recon basics (nmap, tcpdump, dig, ...) stay in the system via
# modules/pentesting.nix. `pkgs` here is built in flake.nix with allowUnfree and
# the unstable overlay, so burpsuite-pro / metasploit / maltego resolve.
{ pkgs }:

let
  # A pentest shell with a short banner listing what it loaded.
  mkPentestShell = name: packages:
    pkgs.mkShellNoCC {
      buildInputs = packages;
      shellHook = ''
        echo ""
        echo "  [${name}] toolset loaded - exit the shell to unload it."
        echo ""
      '';
    };
in
{
  # Web application security.
  appsec = mkPentestShell "appsec" (with pkgs; [
    (unstable.burpsuite.override { proEdition = true; })
    zap             # web application scanner
    nikto           # website vulnerability scanner
    dirb            # web content scanner
    whatweb         # web scanning tool
    gobuster        # web directory scanner
    monsoon         # HTTP enumerator
    feroxbuster     # dirbuster-alike tool
    dalfox          # XSS scanner
    sqlmap          # SQL injection tool
    wpscan          # WordPress vulnerability scanner
    wprecon         # WordPress vulnerability scanner
    wafw00f         # firewall fingerprinting tool
    wfuzz           # web fuzzing tool
    ffuf            # web fuzzer
    mitmproxy       # man-in-the-middle proxy
    mitmproxy2swagger
    updog           # replacement for Python's SimpleHTTPServer
  ]);

  # Network + Active Directory.
  netsec = mkPentestShell "netsec" (with pkgs; [
    # AD / Windows
    python312Packages.impacket
    python312Packages.bloodyad
    python312Packages.roadrecon   # Azure AD recon
    netexec                       # crackmapexec successor
    certipy                       # AD CS abuse
    kerbrute                      # kerberos bruteforce utility
    responder                     # LLMNR/NBT-NS poisoner
    openldap
    ldapdomaindump
    bloodhound-py
    autobloody                    # automatically exploit AD privesc paths
    silenthound                   # lightweight AD enumeration
    adalanche                     # AD ACL visualizer and explorer
    evil-winrm                    # WinRM shell generator
    mimikatz
    powersploit
    go365                         # Office365 enumeration tool
    pysqlrecon                    # offensive MSSQL toolkit
    pkgsCross.mingwW64.buildPackages.gcc  # cross-compile Windows exploits

    # SMB / NetBIOS / RPC
    enum4linux-ng
    smbmap
    samba
    nbtscan
    nbtscanner
    rpcbind
    nfs-utils

    # SNMP
    snmpcheck
    net-snmp
    braa
    onesixtyone

    # DNS enumeration
    dnsrecon
    dnsx
    dnsenum
    fierce

    # Scanning / sniffing / pivoting
    rustscan                      # nmap-alike written in rust
    fping
    wireshark
    tshark
    termshark
    chisel                        # network pivoting tool
    corkscrew                     # tunnel through HTTP proxies
    snicat
    bettercap                     # swiss army knife mitm tool
    websploit                     # MITM framework
    firewalk                      # ACL scanner
    ssh-audit
    swaks                         # SMTP test tool
    freerdp                       # RDP tool
    python312Packages.pyftpdlib   # ftp library for python
    oath-toolkit                  # OTP helpers

    # Exploitation / DB clients
    unstable.metasploit
    exploitdb                     # searchsploit
    redis
    mariadb
    sqsh                          # mssql/mysql client
    freetds
    ghost                         # Android exploitation framework
  ]);

  # Wireless.
  wifi = mkPentestShell "wifi" (with pkgs; [
    aircrack-ng
    airgeddon                     # all-in-one wireless attack tool
    wifite2                       # TUI wifi attack software
    bully                         # WPA/WPA2 recovery from WPS
    cowpatty                      # offline WPA/WPA2 dictionary attack
    reaverwps                     # wifi brute-forcing tool
    reaverwps-t6x
    pixiewps                      # offline WPS brute-forcing
    hcxdumptool                   # packet capture from wlan devices
    hcxtools
    hostapd-mana                  # rogue access point tool
    linux-router                  # wifi hotspot/proxy in one command
    dbmonster                     # wifi-strength scanner
  ]);

  # Forensics, stego, and reverse engineering.
  forensics = mkPentestShell "forensics" (with pkgs; [
    # Forensics / recovery
    foremost
    binwalk
    testdisk
    aeskeyfind                    # find AES keys in a memory image
    # Stego
    exiftool
    steghide
    stegseek
    stegsolve
    zsteg
    outguess
    pngcheck
    # Reverse engineering
    ghidra
    avalonia-ilspy                # decompile .NET assemblies
    upx                           # executable packer
  ]);

  # OSINT / recon.
  osint = mkPentestShell "osint" (with pkgs; [
    theharvester                  # OSINT recon tool
    maltego                       # OSINT recon tool
    sherlock                      # OSINT username tracker
    uncover                       # shodan-ish exposed-host scanner
    subfinder                     # subdomain discovery
    amass                         # subdomain discovery
    trufflehog                    # find credentials
  ]);

  # Password / hash cracking and wordlists.
  cracking = mkPentestShell "cracking" (with pkgs; [
    hashcat
    ocl-icd                       # OpenCL loader for hashcat
    opencl-headers
    zlib
    john                          # john the ripper
    ophcrack-cli                  # rainbow-table cracker
    hydra-cli
    thc-hydra                     # network logon cracker
    medusa                        # ftp brute-forcer
    crowbar                       # brute-forcing tool
    hash-identifier
    hashid
    # Wordlist generation / manipulation
    crunch
    cewl
    rsmangler
    username-anarchy
    creds                         # default-credential search
  ]);

  # Existing BloodHound + neo4j shell (unchanged, just folded in here).
  bloodhound = (import ../bloodhound.nix { inherit pkgs; }).devShells.bloodhound;
}
