#!/run/current-system/sw/bin/bash

# nixos-rebuild action to run - defaults to switch for normal day-to-day
# rebuilds. nixsetup.sh overrides this to "boot" for first-time guest
# setup, so the new generation is staged for the next boot instead of
# switching the live session out from under a fresh install.
readonly NIXBUILD_ACTION="${NIXBUILD_ACTION:-switch}"

# The flake only has two outputs: guest (lean VM guest) and host (bare
# metal, hosts VMs/containers). Pass "guest" or "host" as $1 to force one,
# otherwise it is picked from whether we're running under a hypervisor.
TARGET="${1:-auto}"

if [ "$TARGET" = "auto" ]; then
    if systemd-detect-virt --vm --quiet; then
        TARGET="guest"
    else
        TARGET="host"
    fi
fi

case "$TARGET" in
    guest|host) ;;
    *)
        echo "Unknown target: $TARGET (expected guest or host)" >&2
        exit 1
        ;;
esac

ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    echo "Unsupported architecture: $ARCH (only x86_64 outputs exist in flake.nix)" >&2
    exit 1
fi

echo "Building $TARGET configuration ($NIXBUILD_ACTION)..."
sudo nixos-rebuild "$NIXBUILD_ACTION" --impure --show-trace --option warn-dirty false --flake ~/dotfiles#"$TARGET"
