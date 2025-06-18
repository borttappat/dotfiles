# modules/gaming-performance.nix
# Gaming Performance Module - Bazzite-inspired optimizations for NixOS
# Based on Bazzite's kernel, scheduler, and system optimizations
# Completely Claude-generated, very much WIP

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.gaming.performance;
in

{
  options.gaming.performance = {
    enable = mkEnableOption "gaming performance optimizations";

    scheduler = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gaming-optimized CPU scheduler settings";
      };
      
      type = mkOption {
        type = types.enum [ "bore" "cfs-optimized" "default" ];
        default = "cfs-optimized";
        description = ''
          CPU scheduler optimization type:
          - bore: BORE scheduler (requires kernel rebuild)
          - cfs-optimized: CFS with gaming-specific tweaks
          - default: No scheduler changes
        '';
      };
    };

    io = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gaming-optimized I/O scheduler";
      };
      
      scheduler = mkOption {
        type = types.enum [ "kyber" "bfq" "mq-deadline" ];
        default = "kyber";
        description = "I/O scheduler for gaming (kyber recommended for SSDs)";
      };
    };

    kernel = {
      enableGameParams = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gaming-specific kernel parameters";
      };
      
      enableFsync = mkOption {
        type = types.bool;
        default = true;
        description = "Enable fsync/winesync support for better game compatibility";
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
        default = 30;
        description = "ZRAM memory percentage (lower = more RAM for games)";
      };
    };

    audio = {
      enableLowLatency = mkOption {
        type = types.bool;
        default = true;
        description = "Enable low-latency audio optimizations";
      };
    };

    gpu = {
      enableOptimizations = mkOption {
        type = types.bool;
        default = true;
        description = "Enable GPU-specific gaming optimizations";
      };
    };

    scripts = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install gaming performance management scripts";
      };
    };
  };

  config = mkIf cfg.enable {
    
    # ========================================
    # KERNEL CONFIGURATION
    # ========================================
    
    # Gaming-optimized kernel parameters
    boot.kernelParams = mkIf cfg.kernel.enableGameParams (
      [
        # CPU optimizations
        "preempt=voluntary"              # Better for gaming workloads than full preemption
        "split_lock_detect=off"          # Disable split-lock detection for performance
        
        # Memory management - critical for games with large memory requirements
        "vm.max_map_count=2147483642"    # Required for games like CS2, some Proton games
        "transparent_hugepage=madvise"   # Use hugepages only when requested
        
        # Audio optimizations
        "snd_hda_intel.power_save=0"     # Disable audio power saving to reduce latency
        
        # I/O optimizations
        "scsi_mod.use_blk_mq=1"         # Enable block multiqueue for better performance
        "dm_mod.use_blk_mq=1"           # Enable multiqueue for device mapper
      ] ++ optionals cfg.kernel.disableMitigations [
        # WARNING: These reduce security but improve performance
        "mitigations=off"                # Disable all CPU vulnerability mitigations
        "spectre_v2=off"                # Disable Spectre v2 mitigation
        "spec_store_bypass_disable=off"  # Disable SSBD mitigation
      ]
    );

    # Fsync/Winesync kernel support for better game compatibility
    boot.kernelPatches = mkIf cfg.kernel.enableFsync [
      {
        name = "winesync-fsync-support";
        patch = null;
        extraConfig = ''
          # Wine synchronization primitives for better game performance
          WINESYNC y
          FUTEX y
          FUTEX2 y
        '';
      }
    ] ++ optionals (cfg.scheduler.type == "bore") [
      {
        name = "bore-scheduler";
        patch = null;
        extraConfig = ''
          # BORE (Burst-Oriented Response Enhancer) scheduler
          # Optimizes for interactive/gaming workloads
          SCHED_BORE y
        '';
      }
    ];

    # ========================================
    # CPU SCHEDULER OPTIMIZATIONS
    # ========================================
    
    # Gaming-optimized scheduler settings
    boot.kernel.sysctl = mkIf cfg.scheduler.enable (mkMerge [
      (mkIf (cfg.scheduler.type == "cfs-optimized") {
        # CFS (Completely Fair Scheduler) gaming optimizations
        "kernel.sched_childolatency" = 1000000;        # Reduce child task latency
        "kernel.sched_autogroup_enabled" = 0;          # Disable autogroup for consistent performance
        "kernel.sched_cfs_bandwidth_slice_us" = 3000;  # Smaller bandwidth slices
        
        # Gaming-specific scheduler features
        # NO_GENTLE_FAIR_SLEEPERS: Don't penalize tasks that sleep (like games waiting for vsync)
        # NO_START_DEBIT: Don't penalize new tasks
        "kernel.sched_features" = mkForce "NO_GENTLE_FAIR_SLEEPERS,NO_START_DEBIT";
      })
      
      # Memory and performance optimizations
      {
        # Virtual memory optimizations for gaming
        "vm.swappiness" = mkIf cfg.memory.enableZramOptimization (mkForce 1);  # Aggressive RAM usage
        "vm.vfs_cache_pressure" = 50;                   # Balance between cache and memory
        "vm.dirty_ratio" = 15;                          # Start writing dirty pages earlier
        "vm.dirty_background_ratio" = 5;                # Background writing threshold
        "vm.dirty_writeback_centisecs" = 1500;          # Write dirty pages every 15 seconds
        
        # Network optimizations for online gaming
        "net.core.rmem_default" = 262144;               # Default socket receive buffer
        "net.core.rmem_max" = 16777216;                 # Max socket receive buffer
        "net.core.wmem_default" = 262144;               # Default socket send buffer  
        "net.core.wmem_max" = 16777216;                 # Max socket send buffer
        "net.core.netdev_max_backlog" = 5000;           # Network device backlog queue
        
        # File descriptor limits for games that open many files
        "fs.file-max" = 2097152;                        # System-wide file descriptor limit
      }
    ]);

    # ========================================
    # I/O SCHEDULER OPTIMIZATIONS  
    # ========================================
    
    # Set gaming-optimized I/O schedulers per device type
    services.udev.extraRules = mkIf cfg.io.enable ''
      # Set I/O scheduler based on drive type and gaming preference
      # Kyber: Best for NVMe SSDs and gaming (low latency)
      # BFQ: Good for SATA SSDs and mixed workloads
      # MQ-Deadline: Fallback for older hardware
      
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${cfg.io.scheduler}"
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="${cfg.io.scheduler}"
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    '';

    # ========================================
    # MEMORY MANAGEMENT
    # ========================================
    
    # Gaming-optimized ZRAM configuration
    zramSwap = mkIf cfg.memory.enableZramOptimization {
      enable = mkForce true;
      algorithm = mkForce "zstd";                       # Best compression for gaming
      memoryPercent = mkForce cfg.memory.zramPercent;   # Configurable memory percentage
      priority = mkForce 100;                           # Higher priority than disk swap
    };

    # ========================================
    # AUDIO OPTIMIZATIONS
    # ========================================
    
    # Low-latency audio for gaming
    services.pipewire = mkIf cfg.audio.enableLowLatency {
      enable = mkDefault true;
      alsa.enable = mkDefault true;
      pulse.enable = mkDefault true;
      jack.enable = mkDefault true;
      
      # Gaming-optimized audio configuration
      extraConfig.pipewire."10-gaming" = {
        context.properties = {
          default.clock.rate = 48000;           # Standard gaming audio rate
          default.clock.quantum = 64;           # Low latency buffer size
          default.clock.min-quantum = 16;       # Minimum buffer for ultra-low latency
          default.clock.max-quantum = 8192;     # Maximum buffer size
        };
      };
    };

    # ========================================
    # GPU OPTIMIZATIONS
    # ========================================
    
    # Enhanced hardware acceleration and GPU settings
    hardware.graphics = mkIf cfg.gpu.enableOptimizations {
      enable = mkForce true;
      enable32Bit = mkForce true;
      
      # Additional packages for hardware acceleration
      extraPackages = with pkgs; [
        intel-media-driver    # Intel GPU acceleration
        vaapiIntel           # Intel VAAPI support  
        vaapiVdpau           # VDPAU to VAAPI bridge
        libvdpau-va-gl       # VDPAU support
        intel-compute-runtime # Intel OpenCL runtime
        amdvlk               # AMD Vulkan driver
      ];
    };

    # GPU-specific udev rules for gaming
    services.udev.extraRules = mkIf cfg.gpu.enableOptimizations ''
      # NVIDIA persistence mode for consistent performance
      SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="nvidia", RUN+="${pkgs.writeShellScript "nvidia-persistence" ''
        ${pkgs.nvidia-persistenced}/bin/nvidia-persistenced --persistence-mode 2>/dev/null || true
      ''}"
      
      # Set GPU power profile for gaming
      SUBSYSTEM=="drm", KERNEL=="card*", RUN+="${pkgs.writeShellScript "gpu-gaming-mode" ''
        echo performance > /sys/class/drm/$kernel/device/power_dpm_force_performance_level 2>/dev/null || true
      ''}"
    '';

    # ========================================
    # GAMING SERVICES AND PACKAGES
    # ========================================
    
    # GameMode - automatic performance optimizations when gaming
    programs.gamemode = {
      enable = mkDefault true;
      settings = {
        general = {
          renice = 10;                    # Higher priority for games
          ioprio = 7;                     # Higher I/O priority for games
          inhibit_screensaver = 1;        # Prevent screen blanking during games
        };
        
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          nv_powermizer_mode = 1;         # NVIDIA maximum performance mode
          amd_performance_level = "high"; # AMD high performance mode
        };
        
        cpu = {
          park_cores = "no";              # Keep all CPU cores active
          pin_cores = "yes";              # Pin game processes to specific cores
        };
      };
    };

    # Gaming-related packages with optimizations
    environment.systemPackages = with pkgs; mkIf cfg.scripts.enable [
      # Core gaming tools
      gamemode           # Automatic game optimizations
      gamescope         # Gaming-focused Wayland compositor
      mangohud          # Gaming overlay for performance monitoring
      
      # Performance monitoring and control
      nvtopPackages.full    # GPU monitoring
      btop                  # System monitoring
      
      # Gaming performance scripts
      (writeShellScriptBin "gaming-mode" ''
        #!/bin/sh
        # Activate maximum gaming performance mode
        echo "🎮 Activating Gaming Mode..."
        
        # CPU Performance
        echo "Setting CPU governor to performance..."
        echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
        
        # I/O Performance  
        echo "Optimizing I/O schedulers..."
        for disk in /sys/block/*/queue/scheduler; do
          echo ${cfg.io.scheduler} | sudo tee "$disk" 2>/dev/null || true
        done
        
        # GPU Performance (NVIDIA)
        if command -v nvidia-settings >/dev/null 2>&1; then
          echo "Setting NVIDIA to maximum performance..."
          nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1" >/dev/null 2>&1 || true
        fi
        
        # Memory optimizations
        echo "Optimizing memory management..."
        echo 1 | sudo tee /proc/sys/vm/compact_memory >/dev/null
        echo 1 | sudo tee /proc/sys/vm/drop_caches >/dev/null
        
        # Process priorities for gaming
        echo "Setting up CPU isolation..."
        sudo systemctl set-property --runtime user.slice AllowedCPUs=0-1 2>/dev/null || true
        sudo systemctl set-property --runtime system.slice AllowedCPUs=2-$(nproc --all) 2>/dev/null || true
        
        echo "✅ Gaming mode activated! Use 'standard-mode' to restore normal settings."
      '')
      
      (writeShellScriptBin "standard-mode" ''
        #!/bin/sh
        # Restore standard performance settings
        echo "🔧 Restoring Standard Mode..."
        
        # CPU balanced
        echo "Restoring CPU governor to schedutil..."
        echo schedutil | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
        
        # NVIDIA auto mode
        if command -v nvidia-settings >/dev/null 2>&1; then
          echo "Setting NVIDIA to adaptive mode..."
          nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=0" >/dev/null 2>&1 || true
        fi
        
        # Reset CPU isolation
        echo "Removing CPU isolation..."
        sudo systemctl set-property --runtime user.slice AllowedCPUs= 2>/dev/null || true
        sudo systemctl set-property --runtime system.slice AllowedCPUs= 2>/dev/null || true
        
        echo "✅ Standard mode restored!"
      '')
      
      (writeShellScriptBin "gaming-status" ''
        #!/bin/sh
        # Show current gaming performance status
        echo "🎮 Gaming Performance Status"
        echo "=========================="
        
        echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'Unknown')"
        echo "I/O Scheduler (sda): $(cat /sys/block/sda/queue/scheduler 2>/dev/null | grep -o '\[.*\]' | tr -d '[]' || echo 'Unknown')"
        
        if command -v nvidia-smi >/dev/null 2>&1; then
          echo "GPU Status:"
          nvidia-smi --query-gpu=name,power.draw,clocks.current.graphics --format=csv,noheader,nounits 2>/dev/null || echo "  Unable to query NVIDIA GPU"
        fi
        
        echo "Memory Usage: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
        echo "ZRAM Status: $(zramctl 2>/dev/null | tail -n +2 || echo 'Not active')"
      '')
    ];

    # ========================================
    # SECURITY AND LIMITS
    # ========================================
    
    # Increase file descriptor limits for gaming
    security.pam.loginLimits = [
      {
        domain = "*";
        type = "soft"; 
        item = "nofile";
        value = "524288";  # Higher limit for games that open many files
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile"; 
        value = "1048576";
      }
    ];

    # Gaming-optimized systemd settings
    systemd.extraConfig = ''
      # Faster shutdown for gaming systems
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=10s
    '';

    # ========================================
    # BOOT OPTIMIZATIONS
    # ========================================
    
    # Faster boot times
    boot.loader.timeout = mkDefault 1;
    boot.initrd.systemd.enable = mkDefault true;
    
    # Early OOM killer to prevent system freezes during intense gaming
    services.earlyoom = {
      enable = mkDefault true;
      freeMemThreshold = mkDefault 5;    # Kill processes when RAM < 5%
      freeSwapThreshold = mkDefault 10;   # Kill processes when swap < 10% 
      enableNotifications = mkDefault true;
    };
  };
}
