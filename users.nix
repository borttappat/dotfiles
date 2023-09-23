{ config, pkgs, ... }:

{

# Removing need for user "traum" to type password after sudo
# Add your username here in place of "traum"
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
