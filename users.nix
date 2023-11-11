#                                      _
#   __  __________  __________  ____  (_)  __
#  / / / / ___/ _ \/ ___/ ___/ / __ \/ / |/_/
# / /_/ (__  )  __/ /  (__  ) / / / / />  <
# \__,_/____/\___/_/  /____(_)_/ /_/_/_/|_|

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
