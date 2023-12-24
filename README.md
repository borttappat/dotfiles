### Dofiles!

dotfiles Repo where I put stuff I want to use on multiple machines.
Currently setting up a NixOS system and will do so for the foreseeable future.

![Screenshot](https://github.com/borttappat/dotfiles/blob/main/2023-07-23_18-08.png)

Flakey Nix-configuration with modules split into "configuration.nix, hosts.nix, nixp.nix, packages.nix, services.nix and user.nix"

## link_file.py
```
python link_file.py --files [FILE] --dirs [DIRECTORY]
```
link_file.py checks for parsed directories and creates it if it's missing, deletes file(s) with the name of the parsed file and then creates a link to the specified directory. 
TODO: back up any existing file instead of deleting

links.sh runs through a list of files and directories to link files to in order to ensure that things work correctly.


## Nixp.sh
nixp.nix along with the scripts nixp.sh and nixpsort.py along with related aliases in config.fish allows you to install packages with prompts like:
```
~ nixp neofetch
```
to install neofetch, or
```
~ nixp neofetch htop
```
to install neofetch and htop

You'll then be given a (Y/N) to rebuild your system after the inputs have been parsed.


## Walrgb.sh
simple combination of wal and openrgb. Accepts the path of an image file like 
```
~ walrgb  [PATH/TO/IMAGE] 
```
and then reads the color codes from the cache provided by pywal, converts them to a format OpenRGB then can read and sets the backlight color to the device specified in the script.

## nixsetup.sh
script to be used on any system to an environment like my own with 
#i3, alacritty, fish, picom, Xmodmap and programs listed in packages.nix and nixp.nix along with services in services.nix. Currently set up to backup any existing configuration.nix and implement everything in this repo while preserving usernames.
TODO: set up some sort of automatic bootloader-selection.
