{ config, pkgs, lib, ... }:

{
  imports = [ ./user-detection.nix ];

  # Define user dynamically
  users.users.${config.currentUser} = {
    isNormalUser = true;
    description = "Main User";
    extraGroups = [ "docker" "audio" "networkmanager" "wheel" "wireshark" "adbusers" ];
    createHome = true;
    useDefaultShell = true;
  };

  services.getty.autologinUser = config.currentUser;

  # No password sudo for current user
  security.sudo.extraRules = [
    { users = [ config.currentUser ];
      commands = [
        { command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
