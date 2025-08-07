#!/usr/bin/env bash

VM_NAME="$1"
if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 <vm-name>"
    exit 1
fi

# Launch graphical VM viewer with SPICE features
virt-viewer --connect qemu:///system --wait --reconnect "$VM_NAME"
