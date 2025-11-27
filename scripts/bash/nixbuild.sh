#!/run/current-system/sw/bin/bash

# Get architecture
ARCH=$(uname -m)
# Get hardware vendor information
VENDOR=$(hostnamectl | grep -i "Hardware Vendor" | awk -F': ' '{print $2}' | xargs)

# Check for ARM architecture (including Apple hardware)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] || [[ "$VENDOR" == *"Apple"* && ("$ARCH" == *"arm"* || "$ARCH" == *"aarch"*) ]]; then
    echo "Detected ARM architecture, building ARM configuration"
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#armVM
    exit $?
fi

# Get hardware information for x86 systems
current_host=$(hostnamectl | grep -i "Hardware Vendor")
current_model=$(hostnamectl | grep -i "Hardware Model")

# For Razer-hosts
if echo "$current_host" | grep -q "Razer"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#razer

# For Virtual machines
elif echo "$current_host" | grep -q "QEMU\|VMware"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#VM

# For ASUS Zenbook specifically (check model line for "Zenbook")
elif echo "$current_model" | grep -qi "zenbook"; then
    # Detect current specialisation by checking system state
    if lsmod | grep -q vfio_pci && [[ -d /sys/class/net/virbr1 ]]; then
        CURRENT_LABEL="router-setup"
    else
        CURRENT_LABEL="base-setup"
    fi
    echo "Current system: $CURRENT_LABEL (detected from system state)"

    case "${1:-auto}" in
        "router-boot")
            echo "Building zenbook with router specialisation, staging for boot..."
            sudo nixos-rebuild boot --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zenbook
            echo " Built. Reboot to activate router mode (automatic detection enabled)"
            ;;
        "router-switch")
            echo "Building zenbook and switching to router specialisation..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zenbook
            echo "Activating router specialisation..."
            sudo /run/current-system/specialisation/router/bin/switch-to-configuration switch
            echo "Running mode maintenance..."
            sudo systemctl start splix-post-rebuild-maintenance
            echo " Router mode activated"
            ;;
        "base-switch")
            echo "Building zenbook and staying in base mode..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zenbook
            echo " Base mode active (router specialisation available)"
            ;;
        *)
            echo "Building zenbook and maintaining current mode ($CURRENT_LABEL)..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zenbook

            # Use new automatic mode maintenance instead of deprecated commands
            if [[ "$CURRENT_LABEL" == "router-setup" ]]; then
                echo "Maintaining router mode configuration..."
                # Activate router specialisation if we were in router mode
                sudo /run/current-system/specialisation/router/bin/switch-to-configuration switch
            fi
            
            # Run automatic mode maintenance
            echo "Running automatic mode maintenance..."
            sudo systemctl start splix-post-rebuild-maintenance
            echo " Mode maintenance complete. Current mode: $CURRENT_LABEL"
            ;;
    esac

# For zephyrus machines (zephyrus)
elif echo "$current_model" | grep -qi "zephyrus"; then
    # Detect current specialisation by checking system.nixos.label
    if [[ -f /run/current-system/nixos-version ]]; then
        SYSTEM_LABEL=$(cat /run/current-system/sw/bin/nixos-version 2>/dev/null | grep -oP 'nixos-system-\K[^-]+' || echo "unknown")
    fi

    # Better detection: check the actual system label from the running config
    CURRENT_LABEL="base-setup"  # Default

    if [[ -f /etc/os-release ]]; then
        # Check for maximalism, router, or fallback in the system configuration
        if grep -q "maximalism" /run/current-system/configuration-name 2>/dev/null; then
            CURRENT_LABEL="maximalism-setup"
        elif grep -q "fallback" /run/current-system/configuration-name 2>/dev/null; then
            CURRENT_LABEL="fallback-setup"
        elif grep -q "router" /run/current-system/configuration-name 2>/dev/null; then
            CURRENT_LABEL="router-setup"
        fi
    fi

    # Fallback: Check specialisation symlink
    if [[ "$CURRENT_LABEL" == "base-setup" && -L /run/current-system/specialisation ]]; then
        ACTIVE_SPEC=$(readlink /run/current-system/specialisation | xargs basename 2>/dev/null || echo "none")
        if [[ "$ACTIVE_SPEC" == "maximalism" ]]; then
            CURRENT_LABEL="maximalism-setup"
        elif [[ "$ACTIVE_SPEC" == "fallback" ]]; then
            CURRENT_LABEL="fallback-setup"
        elif [[ "$ACTIVE_SPEC" == "router" ]]; then
            CURRENT_LABEL="router-setup"
        fi
    fi

    # Additional fallback: Check running VMs as last resort
    if [[ "$CURRENT_LABEL" == "base-setup" ]]; then
        PENTEST_RUNNING=$(sudo virsh list --name 2>/dev/null | grep -c "pentest-vm-auto" || echo "0")
        ROUTER_RUNNING=$(sudo virsh list --name 2>/dev/null | grep -c "router-vm" || echo "0")

        if [[ "$PENTEST_RUNNING" -gt 0 && "$ROUTER_RUNNING" -gt 0 ]]; then
            CURRENT_LABEL="maximalism-setup"
        elif [[ "$ROUTER_RUNNING" -gt 0 ]]; then
            CURRENT_LABEL="router-setup"
        fi
    fi

    echo "Current system: $CURRENT_LABEL (detected from system state)"

    # Handle explicit mode switching commands
    case "${1:-auto}" in
        "fallback-switch")
            echo "Building zephyrus and switching to fallback specialisation..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
            echo "Activating fallback specialisation..."
            sudo /run/current-system/specialisation/fallback/bin/switch-to-configuration switch
            echo "✅ Fallback mode activated (clean configuration, no special rules)"
            ;;
        "router-switch")
            echo "Building zephyrus and switching to router specialisation..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
            echo "Activating router specialisation..."
            sudo /run/current-system/specialisation/router/bin/switch-to-configuration switch
            echo "✅ Router mode activated"
            ;;
        "maximalism-switch")
            echo "Building zephyrus and switching to maximalism specialisation..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
            echo "Activating maximalism specialisation..."
            sudo /run/current-system/specialisation/maximalism/bin/switch-to-configuration switch
            echo "✅ Maximalism mode activated (Router + Pentest VMs)"
            ;;
        "base-switch")
            echo "Building zephyrus and staying in base mode..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
            echo "✅ Base mode active (specialisations available)"
            ;;
        *)
            # Auto mode: maintain current configuration
            # Build strategy: use 'boot' for router/maximalism to avoid network disruption
            # Use 'switch' for base and fallback modes
            case "$CURRENT_LABEL" in
                "maximalism-setup")
                    echo "Building zephyrus in maximalism mode (requires reboot)..."
                    sudo nixos-rebuild boot --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
                    echo ""
                    echo "✅ Configuration built successfully!"
                    echo "⚠️  Reboot required to apply maximalism mode changes"
                    echo ""
                    echo "To activate: sudo reboot"
                    echo "After reboot, maximalism mode will be active (Router + Pentest VMs)"
                    ;;
                "router-setup")
                    echo "Building zephyrus in router mode (requires reboot)..."
                    sudo nixos-rebuild boot --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
                    echo ""
                    echo "✅ Configuration built successfully!"
                    echo "⚠️  Reboot required to apply router mode changes"
                    echo ""
                    echo "To activate: sudo reboot"
                    echo "After reboot, router mode will be active"
                    ;;
                "fallback-setup")
                    echo "Building zephyrus in fallback mode (live switch)..."
                    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
                    echo "Maintaining fallback specialisation..."
                    sudo /run/current-system/specialisation/fallback/bin/switch-to-configuration switch
                    echo ""
                    echo "✅ Fallback mode configuration applied successfully!"
                    echo "System is ready to use (no reboot needed)"
                    ;;
                "base-setup")
                    echo "Building zephyrus in base mode (live switch)..."
                    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
                    echo ""
                    echo "✅ Base mode configuration applied successfully!"
                    echo "System is ready to use (no reboot needed)"
                    ;;
                *)
                    # Unknown mode - treat as base mode (safest default)
                    echo "Unknown mode, treating as base mode (live switch)..."
                    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
                    echo ""
                    echo "✅ Configuration built successfully!"
                    ;;
            esac
            ;;
    esac

# === ADD NEW ROUTER MACHINES HERE ===
# 
# To add router support for a new machine:
# 1. Run: ./scripts/generate-all-configs.sh
# 2. Copy the generated block from: generated/nixbuild-entries/{machine}-PASTE-INTO-NIXBUILD.txt
# 3. Paste it above this comment
#
# Example format:
# elif echo "$current_model" | grep -qi "your-machine"; then
#     # Router specialization logic here
# 

# For other Asus-hosts
elif echo "$current_host" | grep -q "ASUS"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#asus

# For Schenker machines
elif echo "$current_host" | grep -q "Schenker"; then
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#xmg

# Check again for Apple vendor as fallback ARM detection
elif [[ "$VENDOR" == *"Apple"* ]]; then
    echo "Detected Apple hardware, assuming ARM architecture"
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#armVM

# Fallback for other or new hardware, simpler configuration
else
    echo "Unknown host: $current_host, building default version. Modify flake.nix to adjust according to preferences"
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#default
fi
