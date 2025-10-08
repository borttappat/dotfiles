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
    10.10.11.20 editorial.htb
    10.10.11.23 permx.htb
    10.10.11.23 lms.permx.htb
    10.10.10.117 irked.htb
    10.10.11.25 greenhorn.htb
    10.10.11.19 app.blurry.htb
    10.10.11.32 sightless.htb
    10.10.11.32 sqlpad.sightless.htb
    #10.10.11.32 admin.sightless.htb
    10.10.11.196 stocker.htb
    10.10.11.44 alert.htb
    #10.10.11.47 extras.linkvortex.htb
    10.10.11.47 dev.linkvortex.htb
    10.10.11.47 linkvortex.htb
    10.10.11.51 sequel.htb
    10.10.11.48 underpass.htb
    10.10.11.41 certified.htb dc01.certified.htb
    10.10.10.239 love.htb staging.love.htb
    10.10.11.57 cypher.htb
    10.10.11.59 strutted.htb
    10.10.11.61 haze.htb
    10.10.10.110 gogs.craft.htb craft.htb api.craft.htb


    # GOAD
    10.3.10.10   sevenkingdoms.local kingslanding.sevenkingdoms.local kingslanding
    10.3.10.11   winterfell.north.sevenkingdoms.local north.sevenkingdoms.local winterfell
    10.3.10.12   essos.local meereen.essos.local meereen
    10.3.10.22   castelblack.north.sevenkingdoms.local castelblack
    10.3.10.23   braavos.essos.local braavos
    
    '';
}

