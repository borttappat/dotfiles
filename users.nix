{ config, pkgs, ... }:

{

# Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.traum = {
        isNormalUser = true;
        description = "A";
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
        ];
    };


# Removing need for user "traum" to type password after sudo
    security.sudo.extraRules= [
    {users = [ "traum" ];
        commands = [
            { command = "ALL" ;
          options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
            }
            ];
    }
    ];
}
