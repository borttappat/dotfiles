{ config, pkgs, ... }: let
  my-alsa-ucm = pkgs.alsa-ucm-conf.overrideAttrs (oldAttrs: {
    src = fetchTarball {
      url = "https://github.com/alsa-project/alsa-ucm-conf/archive/fc17ed4.tar.gz";
      sha256 = "sha256:0krh3r9frzjcv0gj85dljb9776mfjmw18m0ph9lf3n0n4b129xzz";
    };
    installPhase = ''
      mkdir -p $out/share/alsa
      cp -r ucm2 $out/share/alsa/
    '';
    postInstall = "";
  });

  env = {
    ALSA_CONFIG_UCM = "${my-alsa-ucm}/share/alsa/ucm";
    ALSA_CONFIG_UCM2 = "${my-alsa-ucm}/share/alsa/ucm2";
  };
in {

# Intel graphics and hardware acceleration
hardware.graphics.extraPackages = with pkgs; [
  intel-media-driver
  vaapiIntel
  vaapiVdpau
  libvdpau-va-gl
];

# Intel CPU optimizations
hardware.cpu.intel.updateMicrocode = true;

# Enable power management services
#services.power-profiles-daemon.enable = true;
services.thermald.enable = true;

# Basic Intel OpenCL support
environment.systemPackages = with pkgs; [
  intel-compute-runtime
  ocl-icd
  alsa-topology-conf
  alsa-firmware
  alsa-utils
  my-alsa-ucm
];

# Enable bluetooth
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
};

services.blueman.enable = true;

# Audio configuration for Lunar Lake
environment.variables = env;
environment.sessionVariables = env;
systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM = config.environment.variables.ALSA_CONFIG_UCM;
systemd.user.services.pipewire.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM = config.environment.variables.ALSA_CONFIG_UCM;
systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;

hardware.firmware = [
  pkgs.sof-firmware
  pkgs.linux-firmware
  pkgs.alsa-firmware
];

}
