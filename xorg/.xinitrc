#!/run/current-system/sw/bin/bash

unclutter -grab &
wal -Rn &
#mullvad connect & 
#picom -b

# Start spice-vdagent if inside a VM
hostname=$(hostnamectl | grep "Icon name:" | cut -d ":" -f2 | xargs)
if [[ $hostname =~ [vV][mM] ]]; then
    spice-vdagent -x &
fi

#exec i3
exec ~/dotfiles/scripts/bash/i3launch.sh




