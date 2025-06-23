# modules/gaming.nix
# Complete Gaming Performance Module - Bazzite-inspired optimizations for NixOS
# Designed for Zenbook S14 and other gaming laptops

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.gaming.performance;
in

{
  options.gaming.performance = {
    enable = mkEnableOption "gaming performance optimizations";

    kernel = {
      useZenKernel = mkOption {
        type = types.bool;
        default = true;
        description = "Use Zen kernel for better gaming performance";
      };
      
      enableGameParams = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gaming-specific kernel parameters";
      };
      
      disableMitigations = mkOption {
        type = types.bool;
        default = false;
        description = "Disable CPU mitigations for performance (REDUCES SECURITY)";
      };
    };

    memory = {
      enableZramOptimization = mkOption {
        type = types.bool;
        default = true;
        description = "Override ZRAM settings with gaming-optimized values";
      };
      
      zramPercent = mkOption {
        type = types.int;
        default = 25;
        description = "ZRAM memory percentage (25% = 4GB on 16GB system)";
      };
    };

    audio = {
      enableLowLatency = mkOption {
        type = types.bool;
        default = true;
        description = "Enable low-latency audio optimizations";
      };
    };

    display = {
      enableRefreshRateOptimization = mkOption {
        type = types.bool;
        default = true;
        description = "Enable high refresh rate optimizations";
      };
      
      maxRefreshRate = mkOption {
        type = types.int;
        default = 120;
        description = "Maximum supported refresh rate";
      };
    };

    network = {
      enableOptimizations = mkOption {
        type = types.bool;
        default = true;
        description = "Enable network optimizations for gaming";
      };
    };

    power = {
      enableGamingProfile = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gaming-optimized power management";
      };
    };

    gpu = {
      enableOptimizations = mkOption {
        type = types.bool;
        default = true;
        description = "Enable GPU-specific gaming optimizations";
      };
    };

    io = {
      enableOptimizations = mkOption {
        type = types.bool;
        default = true;
        description = "Enable I/O scheduler optimizations";
      };
    };
  };

  config = mkIf cfg.enable {
    
    # ========================================
    # KERNEL CONFIGURATION
    # ========================================
    
    # Use Zen kernel for better gaming performance (higher priority than device configs)
    boot.kernelPackages = mkIf cfg.kernel.useZenKernel (mkOverride 10 pkgs.linuxPackages_zen);
    
    # Gaming-optimized kernel parameters
    boot.kernelParams = mkIf cfg.kernel.enableGameParams (
      [
        # CPU optimizations
        "preempt=full"                  # Full preemption for better responsiveness
        "split_lock_detect=off"         # Disable for game compatibility
        "clearcpuid=514"               # UMIP compatibility for some games
        
        # Memory management
        "transparent_hugepage=madvise"  # Use hugepages only when requested
        
        # Audio optimizations
        "snd_hda_intel.power_save=0"   # Disable audio power saving
        
        # I/O optimizations
        "scsi_mod.use_blk_mq=1"        # Enable block multiqueue
        "dm_mod.use_blk_mq=1"          # Enable multiqueue for device mapper
      ] ++ optionals cfg.kernel.disableMitigations [
        # WARNING: These reduce security but improve performance
        "mitigations=off"
        "spectre_v2=off"
        "spec_store_bypass_disable=off"
      ]
    );

    # Gaming-optimized sysctl settings (with conflict resolution)
    boot.kernel.sysctl = mkIf cfg.kernel.enableGameParams (mkMerge [
      {
        # Memory management optimizations (override conflicting settings)
        "vm.max_map_count" = mkForce 2147483642;     # Required for games like CS2
        "vm.swappiness" = mkIf cfg.memory.enableZramOptimization (mkForce 180);  # High swappiness for ZRAM
        "vm.page-cluster" = mkForce 0;               # Optimize for ZRAM usage
        "vm.vfs_cache_pressure" = mkForce 500;       # Memory pressure handling
        "vm.dirty_background_ratio" = mkForce 1;     # Background writing
        "vm.dirty_ratio" = mkForce 50;               # Dirty page threshold
        "vm.dirty_writeback_centisecs" = mkForce 1500;  # Write frequency
        
        # CPU scheduler optimizations
        "kernel.sched_child_runs_first" = 1;        # New processes run immediately
        "kernel.sched_autogroup_enabled" = 0;       # Disable autogroup
        "kernel.sched_cfs_bandwidth_slice_us" = 3000;  # Smaller bandwidth slices
        
        # File system optimizations
        "fs.file-max" = 2097152;                     # System-wide file descriptor limit
        
        # Process management
        "kernel.task_delayacct" = 1;                 # I/O performance tracking
      }
      
      # Network optimizations
      (mkIf cfg.network.enableOptimizations {
        # BBR TCP congestion control
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        
        # Network buffer optimizations
        "net.core.rmem_default" = 262144;
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_default" = 262144;
        "net.core.wmem_max" = 16777216;
        "net.core.netdev_max_backlog" = 5000;
        
        # TCP optimizations
        "net.ipv4.tcp_rmem" = "4096 65536 16777216";
        "net.ipv4.tcp_wmem" = "4096 65536 16777216";
        "net.ipv4.tcp_slow_start_after_idle" = 0;
      })
    ]);

    # Disable Wi-Fi power saving for reduced latency
    networking.networkmanager.wifi.powersave = mkIf cfg.network.enableOptimizations (mkForce false);

    # ========================================
    # I/O SCHEDULER OPTIMIZATIONS
    # ========================================
    
    services.udev.extraRules = mkIf cfg.io.enableOptimizations ''
      # Gaming-optimized I/O schedulers
      # Kyber: Best for NVMe SSDs and gaming (low latency)
      # BFQ: Good for SATA SSDs and mixed workloads
      # MQ-Deadline: Fallback for older hardware
      
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="kyber"
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      
      # Optimize queue depths for gaming
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/nr_requests}="256"
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/nr_requests}="128"
    '';

    # ========================================
    # MEMORY MANAGEMENT
    # ========================================
    
    # Gaming-optimized ZRAM configuration (Bazzite uses 4GB ZRAM)
    zramSwap = mkIf cfg.memory.enableZramOptimization (mkForce {
      enable = true;
      algorithm = "zstd";                           # Best compression for gaming
      memoryPercent = cfg.memory.zramPercent;       # Configurable percentage
      priority = 100;                               # Higher priority than disk swap
    });

    # ========================================
    # AUDIO OPTIMIZATIONS - EXTEND EXISTING CONFIG
    # ========================================
    
    # Extend existing PipeWire config with gaming optimizations (don't override completely)
    services.pipewire = mkIf cfg.audio.enableLowLatency {
      # Gaming-optimized audio configuration (extend existing)
      extraConfig.pipewire."10-gaming" = {
        context.properties = {
          default.clock.rate = 48000;               # Standard gaming audio rate
          default.clock.quantum = 64;               # Low latency buffer size
          default.clock.min-quantum = 16;           # Minimum buffer for ultra-low latency
          default.clock.max-quantum = 8192;         # Maximum buffer size
        };
      };
      
      extraConfig.pipewire-pulse."10-gaming" = {
        pulse.properties = {
          pulse.min.req = "16/48000";               # Minimum request size
          pulse.default.req = "64/48000";           # Default request size
          pulse.max.req = "8192/48000";             # Maximum request size
          pulse.min.quantum = "16/48000";           # Minimum quantum
          pulse.max.quantum = "8192/48000";         # Maximum quantum
        };
      };
    };

    # Ensure audio power saving is disabled (but don't conflict with existing config)
    security.rtkit.enable = mkDefault true;

    # ========================================
    # GPU OPTIMIZATIONS
    # ========================================
    
    # Enhanced hardware acceleration
    hardware.graphics = mkIf cfg.gpu.enableOptimizations (mkForce {
      enable = true;
      enable32Bit = true;
      
      extraPackages = with pkgs; [
        # Intel GPU support (for Lunar Lake)
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-compute-runtime
        level-zero
        
        # AMD support
        amdvlk
        
        # General
        mesa
        vulkan-loader
        vulkan-validation-layers
      ];
    });

    # Display optimization for high refresh rates
    environment.variables = mkIf cfg.display.enableRefreshRateOptimization {
      # Enable custom refresh rates up to configured maximum
      CUSTOM_REFRESH_RATES = "30-${toString cfg.display.maxRefreshRate}";
      
      # GPU optimizations
      __GL_SYNC_TO_VBLANK = "0";                   # Disable VSync globally
      __GL_ALLOW_UNOFFICIAL_PROTOCOL = "1";        # Enable unofficial protocols
      
      # Mesa optimizations
      MESA_GLTHREAD = "true";                       # Enable Mesa threading
      mesa_glthread = "true";
      
      # Vulkan optimizations  
      RADV_PERFTEST = "gpl,nggc,sam";              # AMD Vulkan optimizations
      
      # Wine/Proton optimizations
      WINEESYNC = "1";                             # Enable esync
      WINEFSYNC = "1";                             # Enable fsync
    };

    # ========================================
    # POWER MANAGEMENT - CONFLICT RESOLUTION
    # ========================================
    
    # Disable conflicting power management services
    services.auto-cpufreq.enable = mkForce false;
    services.power-profiles-daemon.enable = mkForce false;
    
    # Use TLP as the sole power management solution
    services.tlp = mkIf cfg.power.enableGamingProfile (mkForce {
      enable = true;
      settings = {
        # CPU settings
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        
        # Disk settings
        SATA_LINKPWR_ON_AC = "max_performance";
        SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
        
        # USB autosuspend
        USB_AUTOSUSPEND = 0;                         # Disable USB autosuspend for gaming
        
        # Wi-Fi power management
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "off";
        
        # Gaming-specific optimizations
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 80;                    # Keep some performance on battery
        
        # Platform profiles
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";
        
        # Runtime power management
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
        
        # Sound power savings (disable for gaming)
        SOUND_POWER_SAVE_ON_AC = 0;
        SOUND_POWER_SAVE_ON_BAT = 0;
      };
    });

    # ========================================
    # GAMING SOFTWARE AND SERVICES
    # ========================================
    
    # GameMode for automatic performance optimizations
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;                              # Higher priority for games
          ioprio = 7;                               # Higher I/O priority
          inhibit_screensaver = 1;                  # Prevent screen blanking
          softrealtime = "auto";                    # Enable soft real-time
        };
        
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          nv_powermizer_mode = 1;                   # NVIDIA max performance
          amd_performance_level = "high";           # AMD high performance
        };
        
        cpu = {
          park_cores = "no";                        # Keep all cores active
          pin_cores = "yes";                        # Pin game processes
        };
      };
    };

    # Steam with gaming optimizations
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;               # Enable Gamescope session
    };

    # Hardware support
    hardware.steam-hardware.enable = true;
    hardware.xpadneo.enable = true;                 # Xbox controller support
    hardware.xone.enable = true;                    # Xbox One controller support

    # ========================================
    # SECURITY AND LIMITS - OVERRIDE CONFIGURATION.NIX
    # ========================================
    
    # Increase file descriptor limits for gaming (override configuration.nix settings)
    security.pam.loginLimits = mkForce [
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "524288";
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "1048576";
      }
      {
        domain = "*";
        type = "soft";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "*";
        type = "hard";
        item = "memlock";
        value = "unlimited";
      }
    ];

    # Gaming-optimized systemd settings
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=10s
      DefaultLimitNOFILE=1048576
    '';

    # ========================================
    # GAMING PACKAGES AND TOOLS
    # ========================================
    
    environment.systemPackages = with pkgs; [
      # Core gaming tools
      gamemode
      gamescope
      mangohud
      goverlay                          # MangoHud GUI
      
      # Performance monitoring
      nvtopPackages.full
      btop
      iotop
      
      # Gaming utilities
      steamPackages.steamcmd
      protontricks
      winetricks
      lutris
      bottles
      
      # Audio tools
      pavucontrol
      helvum                            # PipeWire patchbay
      
      # System utilities
      vulkan-tools
      glxinfo
      mesa-demos
      
      # Performance scripts
      (writeShellScriptBin "gaming-mode" ''
        #!/bin/sh
        echo "🎮 Activating Gaming Mode..."
        
        # Set CPU governor to performance
        echo "Setting CPU to performance mode..."
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1 || true
        
        # Optimize I/O schedulers
        echo "Optimizing I/O schedulers..."
        for disk in /sys/block/*/queue/scheduler; do
          if [[ -f "$disk" ]]; then
            echo kyber | sudo tee "$disk" 2>/dev/null || true
          fi
        done
        
        # Memory optimization
        echo "Optimizing memory..."
        echo 1 | sudo tee /proc/sys/vm/compact_memory >/dev/null 2>&1 || true
        echo 1 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1 || true
        
        echo "✅ Gaming mode activated!"
      '')
      
      (writeShellScriptBin "standard-mode" ''
        #!/bin/sh
        echo "🔧 Restoring Standard Mode..."
        
        # Restore CPU governor
        echo "Restoring CPU governor..."
        echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1 || true
        
        echo "✅ Standard mode restored!"
      '')
      
      (writeShellScriptBin "gaming-status" ''
        #!/bin/sh
        echo "🎮 Gaming Performance Status"
        echo "=========================="
        
        echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'Unknown')"
        echo "I/O Scheduler (nvme0n1): $(cat /sys/block/nvme0n1/queue/scheduler 2>/dev/null | grep -o '\[.*\]' | tr -d '[]' || echo 'Unknown')"
        echo "Memory Usage: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
        echo "ZRAM Status: $(zramctl 2>/dev/null | tail -n +2 || echo 'Not active')"
        echo "Audio Latency: $(cat /proc/asound/card*/pcm*/sub*/status 2>/dev/null | head -1 || echo 'Unknown')"
        
        if command -v nvidia-smi >/dev/null 2>&1; then
          echo "GPU Status:"
          nvidia-smi --query-gpu=name,power.draw,clocks.current.graphics --format=csv,noheader,nounits 2>/dev/null || echo "  Unable to query NVIDIA GPU"
        fi
      '')
    ];

    # ========================================
    # BOOT OPTIMIZATIONS - EXTEND EXISTING CONFIG
    # ========================================
    
    # Faster boot times
    boot.loader.timeout = mkDefault 1;
    boot.initrd.systemd.enable = mkDefault true;
    
    # Early OOM killer settings (extend existing configuration.nix settings)
    services.earlyoom = {
      # Don't override existing settings, just ensure it's enabled
      enable = mkDefault true;
    };
  };
}
