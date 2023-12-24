My dotfiles Repo where I put stuff I want to use on multiple machines.
Currently setting up a NixOS system and will do so for the foreseeable future.

Welcome!

![Screenshot](https://github.com/borttappat/dotfiles/blob/main/2023-07-23_18-08.png)

A few noteworthy includes:

## [Nixp]
nixp.nix along with the scripts nixp.sh and nixpsort.py along with related aliases in config.fish allows you to install packages with prompts like:

> ~ nixp neofetch

to install neofetch, or

> ~ nixp neofetch htop

to install neofetch and htop

You'll then be given a (Y/N) to rebuild after the inputs have been parsed.


## [Walrgb]
simple combination of wal and openrgb. Accepts the path of an image file like 

[wal -i /PATH/TO/IMAGE] 

and then reads the color codes from the cache provided by pywal, converts them to a format OpenRGB then can read and sets the backlight color to the device specified in the script.


