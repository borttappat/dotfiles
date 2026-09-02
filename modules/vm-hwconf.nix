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

  lowerPriority = lib.mapAttrsRecursiveCond
    (v: lib.isAttrs v && !(v ? _type) && !(lib.isDerivation v))
    (_path: lib.mkDefault)
    (builtins.removeAttrs hostConfigRaw [ "imports" ]);
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
}
