{ config, pkgs, lib, ... }:

{
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "acpi_enforce_resources=lax"
    "intel_iommu=igfx_off"
  ];

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  services.thermald.enable = true;

  environment.systemPackages = with pkgs; [
    intel-compute-runtime
    ocl-icd
    alsa-utils
    pavucontrol
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Gaming performance configuration
  gaming.performance = {
    enable = true;
    kernel.useZenKernel = false;        # Keep linuxPackages_latest
    kernel.enableGameParams = true;
    kernel.disableMitigations = false;  # Keep security
    memory.enableZramOptimization = true;
    memory.zramPercent = 25;            # Override configuration.nix 50%
    display.enableRefreshRateOptimization = true;
    display.maxRefreshRate = 120;       # OLED display refresh rate
    network.enableOptimizations = true;
    power.enableGamingProfile = true;   # Use TLP
    gpu.enableOptimizations = true;
    io.enableOptimizations = true;
    audio.enableLowLatency = false;     # Disabled since you removed audio components
  };

  hardware.firmware = [
    pkgs.sof-firmware
    pkgs.linux-firmware
    pkgs.alsa-firmware
  ];
}
