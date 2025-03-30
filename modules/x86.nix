# modules/x86.nix
{ config, lib, pkgs, ... }:

{
  # X86-specific CPU and hardware support
  hardware = {
    cpu = {
      intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
    
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  # X86-specific services
  services.thermald.enable = true;

  # Power management (Intel P-state, etc.)
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # X86-specific boot parameters
  boot.kernelParams = [
    "intel_pstate=active"
  ];
}
