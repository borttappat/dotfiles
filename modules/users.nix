#                                      _
#   __  __________  __________  ____  (_)  __
#  / / / / ___/ _ \/ ___/ ___/ / __ \/ / |/_/
# / /_/ (__  )  __/ /  (__  ) / / / / />  <
# \__,_/____/\___/_/  /____(_)_/ /_/_/_/|_|

{ config, pkgs, username, ... }:

{

# Defining the primary user (name comes from flake.nix `username`).
users.users.${username} = {
    isNormalUser = true;
    description = "A";
    extraGroups = [ "docker" "audio" "networkmanager" "wheel" "wireshark" "adbusers" ];
    createHome = true;
    useDefaultShell = true;
};

services.getty.autologinUser = username;


# Removing need for the primary user to type password after sudo
security.sudo.extraRules= [
    {users = [ username ];
        commands = [
            { command = "ALL" ;
                options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
            }
        ];
    }
];

# The following could maybe replace the above settings?
#   security.sudo.wheelNeedsPassword = false;

}
