{ lib, ... }:

let
  sudoUser = builtins.getEnv "SUDO_USER";
  currentUser = builtins.getEnv "USER";
  detectedUser = if sudoUser != "" then sudoUser else currentUser;
  finalUser = if detectedUser != "" then detectedUser else "traum";
in
{
  options = {
    currentUser = lib.mkOption {
      type = lib.types.str;
      default = finalUser;
      description = "The current user running the configuration";
    };
    
    userHome = lib.mkOption {
      type = lib.types.str;
      default = "/home/${finalUser}";
      description = "Home directory of the current user";
    };
  };
}
