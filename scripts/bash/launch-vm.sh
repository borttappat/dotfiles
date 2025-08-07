#!/usr/bin/env bash

VM_NAME="$1"
RESOLUTION="${2:-1920x1080}"

if [ -z "$VM_NAME" ]; then
echo "Usage: $0 <vm-name> [resolution]"
echo "Example: $0 test-vm 1920x1080"
exit 1
fi

echo "Launching VM: $VM_NAME with resolution: $RESOLUTION"

# Launch with SPICE for clipboard and auto-resize
virt-viewer \
    --connect qemu:///system \
    --wait \
    --reconnect \
    --shared \
    --auto-resize=always \
    --debug \
    "$VM_NAME"
