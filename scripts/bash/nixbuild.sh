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
elif echo "$current_host" | grep -q "QEMU"; then
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
            echo "✅ Built. Reboot, then run 'switch-to-router' for router mode"
            ;;
        "router-switch")
            echo "Building zenbook and switching to router mode..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zenbook
            echo "Switching to router mode..."
            switch-to-router
            ;;
        "base-switch")
            echo "Building zenbook and staying in base mode..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zenbook
            echo "✅ Base mode active"
            ;;
        *)
            echo "Building zenbook and maintaining current mode ($CURRENT_LABEL)..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zenbook

            # Add bridge recreation for router mode
            if [[ "$CURRENT_LABEL" == "router-setup" ]]; then
                echo "Ensuring virbr1 bridge exists for router mode..."
                if ! ip link show virbr1 >/dev/null 2>&1; then
                    sudo ip link add virbr1 type bridge
                    sudo ip addr add 192.168.100.1/24 dev virbr1
                    sudo ip link set virbr1 up
                    echo "✓ virbr1 bridge recreated"
                else
                    echo "✓ virbr1 bridge already exists"
                fi
            fi

            # Switch back to whatever mode we were in
            if [[ "$CURRENT_LABEL" == "router-setup" ]]; then
                echo "Restoring router mode..."
                switch-to-router
            else
                echo "✅ Base mode active. Available commands:"
                echo "  switch-to-router  - Enable router mode with VFIO"
                echo "  switch-to-base    - Return to normal WiFi"
            fi
            ;;
    esac

# For ASUS Zephyrus specifically (check model line for "Zephyrus")
elif echo "$current_model" | grep -qi "zephyrus"; then
    # Detect current specialisation
    CURRENT_LABEL=$(nixos-version | grep -o '[a-zA-Z-]*setup' || echo "base-setup")
    echo "Current system: $CURRENT_LABEL"

    case "${1:-auto}" in
        "router-boot")
            echo "Building zephyrus with router specialisation, staging for boot..."
            sudo nixos-rebuild boot --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
            echo "✅ Built. Reboot, then run 'switch-to-router' for router mode"
            ;;
        "router-switch")
            echo "Building zephyrus and switching to router mode..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
            echo "Switching to router mode..."
            switch-to-router
            ;;
        "base-switch")
            echo "Building zephyrus and staying in base mode..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus
            echo "✅ Base mode active"
            ;;
        *)
            echo "Building zephyrus and maintaining current mode ($CURRENT_LABEL)..."
            sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus

            # Switch back to whatever mode we were in
            if [[ "$CURRENT_LABEL" == "router-setup" ]]; then
                echo "Restoring router mode..."
                switch-to-router
            else
                echo "✅ Base mode active. Available commands:"
                echo "  switch-to-router  - Enable router mode with VFIO"
                echo "  switch-to-base    - Return to normal WiFi"
            fi
            ;;
    esac

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
