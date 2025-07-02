{ lib, ... }:

{
  options = {
    currentUser = lib.mkOption {
      type = lib.types.str;
      default = builtins.getEnv "SUDO_USER";
      description = "The current user running the configuration";
    };
    
    userHome = lib.mkOption {
      type = lib.types.str;
      default = "/home/${builtins.getEnv "SUDO_USER"}";
      description = "Home directory of the current user";
    };
  };
  
  config = lib.mkIf (builtins.getEnv "SUDO_USER" == "") {
    currentUser = lib.mkDefault (builtins.getEnv "USER");
    userHome = lib.mkDefault "/home/${builtins.getEnv "USER"}";
  };
}
