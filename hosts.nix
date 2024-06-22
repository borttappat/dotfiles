#    __  __           __
#   / / / /___  _____/ /______
#  / /_/ / __ \/ ___/ __/ ___/
# / __  / /_/ (__  ) /_(__  )
#/_/ /_/\____/____/\__/____/

{ config, pkgs, ... }:

{

# Modify the following like you would /etc/hosts
    networking.extraHosts =
    ''
    10.129.240.39 unika.htb
    10.129.72.251 thetoppers.htb
    10.129.72.251 s3.thetoppers.htb
    10.129.20.110 ignition.htb
    10.10.11.233 analytical.htb
    10.10.11.233 data.analytical.htb
    10.10.11.227 tickets.keeper.htb/rt/
    10.10.11.219 pilgrimage.htb
    10.10.11.221 2million.htb
    10.10.11.189 precious.htb
    10.10.11.242 devvortex.htb 
    10.10.11.252 bizness.htb
    10.10.11.130 goodgames.htb
    10.10.11.18 usage.htb
    10.10.11.18 admin.usage.htb
    10.10.11.249 crafty.htb
    10.10.11.249 play.crafty.htb
    10.10.11.116 validation.htb
    10.10.10.150 curling.htb
    10.10.10.37 blocky.htb
    10.129.42.195 internal.inlanefreight.htb
    10.129.42.195 ftp.internal.inlanefreight.htb 
    10.10.11.11 board.htb
    10.10.11.19 app.blurry.htb
    10.10.10.11 arctic.htb
    10.10.11.7 wifinetic.htb
    10.10.10.14 grandpa.htb
    10.129.226.104 app.inlanefreight.local
    10.129.226.104 dev.inlanefreight.local
    10.129.157.242  inlanefreight.htb
    10.129.219.41 app.inlanefreight.local
    10.129.219.41 dev.inlanefreight.local

    '';
}

