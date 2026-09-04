{ config, pkgs, lib, ... }@args:
let
  # Everything the installer actually wrote to configuration.nix. Previously
  # this file only cherry-picked grub.device and luks.devices out of it by
  # name - anything else declared there (extra boot/initrd settings, etc.)
  # was silently dropped, since the raw file was only ever called as a plain
  # function, never imported as a real module.
  #
  # Wrap every leaf definition it makes as lib.mkDefault (lowest priority)
  # instead. That way the whole file is imported wholesale - nothing it
  # declares gets lost - while any explicit choice made elsewhere in this
  # repo's own modules (plain assignment, normal priority) still wins on
  # conflict, without needing lib.mkForce sprinkled around by hand.
  hostConfigRaw = import /etc/nixos/configuration.nix args;

  # Desktop/display-manager choice is this repo's call, never the
  # installer's. A graphical install ISO's configuration.nix commonly
  # enables its own desktopManager/displayManager (e.g. XFCE + a display
  # manager) - those are a *different* option path than this repo's own
  # windowManager.i3/displayManager.startx, so they wouldn't conflict and
  # would silently coexist, letting a display manager start XFCE instead
  # of leaving startx/i3 in control. Stripped out before wrapping, under
  # both the old (xserver.displayManager/desktopManager) and current
  # (top-level displayManager/desktopManager) option locations.
  sanitizedHostConfig = hostConfigRaw // {
    services = (builtins.removeAttrs (hostConfigRaw.services or { }) [
      "displayManager"
      "desktopManager"
    ]) // {
      xserver = builtins.removeAttrs (hostConfigRaw.services.xserver or { }) [
        "displayManager"
        "desktopManager"
      ];
    };
  };

  lowerPriority = lib.mapAttrsRecursiveCond
    (v: lib.isAttrs v && !(v ? _type) && !(lib.isDerivation v))
    (_path: lib.mkDefault)
    (builtins.removeAttrs sanitizedHostConfig [ "imports" ]);
in
{
  imports = [
    /etc/nixos/hardware-configuration.nix
    lowerPriority
  ];

  boot.loader.grub = {
    enable = true;
    useOSProber = false;
    # Required for GRUB to read the kernel/initrd when /boot lives inside
    # the LUKS container rather than a separate unencrypted partition.
    # Harmless no-op otherwise.
    enableCryptodisk = true;
  };

  # This repo always drives GRUB (above), never systemd-boot. Force it off
  # explicitly rather than relying on lowerPriority's mkDefault wrapping of
  # whatever the installer picked: systemd-boot's own module sets
  # boot.loader.grub.enable = mkDefault false as its half of the mutual
  # exclusion, so if the installer's config *also* enabled systemd-boot
  # (common on a UEFI VMware guest) both loaders would otherwise end up
  # configured at once. mkForce here is the other, explicit half.
  boot.loader.systemd-boot.enable = lib.mkForce false;
}
