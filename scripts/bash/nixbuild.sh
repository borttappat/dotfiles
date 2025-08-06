#!/run/current-system/sw/bin/bash

# Get architecture
ARCH=$(uname -m)
# Get hardware vendor and model information using hostnamectl
VENDOR=$(hostnamectl | grep -i "Hardware Vendor" | awk -F': ' '{print $2}' | xargs)
MODEL=$(hostnamectl | grep -i "Hardware Model" | awk -F': ' '{print $2}' | xargs)

echo "Detected hardware:"
echo "  Architecture: $ARCH"
echo "  Vendor: $VENDOR"
echo "  Model: $MODEL"

# Check for ARM architecture (including Apple hardware)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] || [[ "$VENDOR" == *"Apple"* && ("$ARCH" == *"arm"* || "$ARCH" == *"aarch"*) ]]; then
    echo "Building ARM configuration..."
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#armVM
    exit $?
fi

# Hardware detection for x86 systems using hostnamectl output
echo "Determining appropriate configuration..."

# For Razer hardware
if [[ "$VENDOR" == *"Razer"* ]]; then
    echo "Detected Razer hardware, building Razer configuration..."
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#razer

# For Virtual machines (QEMU/KVM)
elif [[ "$VENDOR" == *"QEMU"* ]] || [[ "$MODEL" == *"QEMU"* ]]; then
    echo "Detected virtual machine, building VM configuration..."
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#VM 

# For ASUS Zenbook specifically (check model for "Zenbook")
elif [[ "$VENDOR" == *"ASUS"* ]] && [[ "$MODEL" == *"enbook"* ]]; then
    echo "Detected ASUS Zenbook, building Zenbook configuration..."
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zenbook

# For ASUS Zephyrus specifically (check model for "Zephyrus")  
elif [[ "$VENDOR" == *"ASUS"* ]] && [[ "$MODEL" == *"ephyrus"* ]]; then
    echo "Detected ASUS Zephyrus, building Zephyrus configuration..."
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#zephyrus

# Check again for Apple vendor as fallback ARM detection
elif [[ "$VENDOR" == *"Apple"* ]]; then
    echo "Detected Apple hardware, assuming ARM architecture..."
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#armVM

# Fallback for unknown or new hardware
else
    echo "Unknown hardware detected:"
    echo "  Vendor: $VENDOR"
    echo "  Model: $MODEL"
    echo "Building default configuration..."
    echo "You may want to modify flake.nix to add specific support for this hardware"
    sudo nixos-rebuild switch --impure --show-trace --option warn-dirty false --flake ~/dotfiles#default
fi

echo "Build completed successfully!"
