### Dotfiles!

My personal repo where I put stuff I want to use on multiple machines.
Currently setting up a NixOS system and will do so for the foreseeable future.

## TL;DR
Flakey Nix-configuration with modules split into (mainly)"configuration.nix, hosts.nix, nixp.nix, packages.nix, services.nix and user.nix"

![Screenshot](https://github.com/borttappat/dotfiles/blob/main/screenshot.png)


## link.py
```
python link_file.py --file [FILE] --dir [DIRECTORY]
```

[scripts/python/link.py] checks for parsed directories and creates it if it's missing, deletes file(s) with the name of the parsed file and then creates a link to the specified directory. 

TODO: back up any existing file instead of deleting, or similar.

[scripts/bash/links.sh] runs through a list of files and directories to link files to in order to ensure that things work correctly.


## Nixp.sh
Nixp.nix along with the scripts nixp.sh and nixpsort.py along with related aliases in config.fish allows you to install packages with prompts like:
```
nixp neofetch
```
to install neofetch, or
```
nixp neofetch htop
```
to install neofetch and htop

You'll then be given a (Y/N) to rebuild your system after the inputs have been parsed.
nixp.nix is left empty for any user to modify locally

## scripts/bash/walrgb.sh
Simple combination of wal and openrgb. Accepts the path of an image file like 
```
walrgb [PATH/TO/IMAGE]
```
and then reads the color codes from the cache provided by pywal, converts them to a format OpenRGB then can read and sets the backlight color to the device specified in the script.

## scripts/bash/randomwalrgb.sh
Similar to the above script but picks a random .jpg or .png from ~/Wallpapers

## scripts/bash/nixsetup.sh
Script to be used on any system to an environment like my own with 

``
i3, alacritty, fish, picom
``

and programs listed in packages.nix and nixp.nix along with services in services.nix.

Currently set up to backup any existing configuration.nix and implement everything in this repo while preserving usernames and bootloader settings along with hardware-configuration.nix as it is set during installation(left as is for now).

## scripts/bash/nixbuild.sh
Script set up to read the current machine-name and build accordingly, modify the contents of flake.nix to match any desired setup per device if used with multiple devices. Will run as the "default" option if host-name is not any expected setup of mine from this repo.

## scripts/nixupdate.sh
Script set up to update the current flake to the latest version and then rebuilds the system. Used to update kernel, mostly.

