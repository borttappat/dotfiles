{ config, pkgs, ... }:

{
  # X86-specific hardware enablement
  hardware.enableAllFirmware = true;

  # X86-specific graphics settings
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # Only include these on x86
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # X86-specific kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Power management (x86-specific)
  services.thermald.enable = true;
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # X86-specific services
  services.xserver.videoDrivers = [ "modesetting" "intel" ];
}
