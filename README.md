### Dotfiles!

My personal repo where I put stuff I want to use on multiple machines.
Currently setting up a NixOS system and will do so for the foreseeable future.

## TL;DR
Flakey Nix-configuration with modules split into (mainly) ``configuration.nix`` ``hosts.nix`` ``nixp.nix`` ``packages.nix`` ``services.nix`` and ``user.nix``. 

Managed through scripts in ``scripts/bash`` and ``scripts/python`` and configuration files for among others;``i3wm`` ``alaritty`` ``fish`` ``polybar`` and ``picom``.

![Screenshot](https://github.com/borttappat/dotfiles/blob/main/misc/screenshot.png)


### Installation
Commands to run on an (not recommended)existing install or
(recommended) fresh install

Temp-install git and python for cloning repo and running scripts
```
nix-shell -p git python3
```
Clone the repo
```
git clone https://github.com/borttappat/dotfiles
```
Navigate to the scripts-directory
```
cd dotfiles/scripts/bash
```
Make the build-script executable
```
chmod +x nixbuild.sh
```
Run the script
```
./nixbuild.sh
```
Your system will then reboot and you should boot into tty and the command ``x`` will start Xserver and i3(picom for transparency is started at launch, if you're running in a WM I run the following to make it more usable, transparency hasn't worked out well for me in virtual environments): ``killall picom`` 

### Usage

### Info
Keyboard layout is set to Swedish, edit by adjusting the following in ``configuration.nix``
```
141     services.xserver.xkb = {
  1         layout = "se";
  2         variant = "";
  3     };
```
```
  1     console.keyMap = "sv-latin1";
```

Bindings can be found in ``~/dotfiles/i3/config``, but often used ones include:

Super + Return: Launch an Alacritty terminal

Super + c or Super + v: split the way windows open in

Super + d: Launh Rofi, mainly used to search for and launch programs

Super + Shift + i: open the i3 configuration file

Super + Shift + u: open htop

Super + s: open a floating terminal

``f`` is aliased to open your fish-config in which you can find every shortcut to every most scripts
A few useful ones include
``np`` opens a vim-session in which you can edit ``packages.nix`` which determines the packages installed on the system
``nb`` builds the system with the modules listed in ``flake.nix``in the ``"default"`` section(notably includes ``packages.nix``, the referenced script is a bit hacky and involves fething the name using ``neofetch`` in the background, keep that program around or set up new Configurations with other methos, Nix includes this by referencing the hostname, it's worth looking into.
``pc`` opens up a vim-session in which you can edit Picom, the compositor responsible for the transparency
``ac`` opens up a vim-session for editing Alacrittys config file


### scripts/python/link.py
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

### scripts/bash/walrgb.sh
Simple combination of wal and openrgb. Accepts the path of an image file like 
```
walrgb [PATH/TO/IMAGE]
```
and then reads the color codes from the cache provided by pywal, converts them to a format OpenRGB then can read and sets the backlight color to the device specified in the script.

### scripts/bash/randomwalrgb.sh
Similar to the above script but picks a random .jpg or .png from ~/Wallpapers

### scripts/bash/nixsetup.sh
Script to be used on any system to an environment like my own with 

``
i3, alacritty, fish, picom
``

and programs listed in packages.nix and nixp.nix along with services in services.nix.

Currently set up to backup any existing configuration.nix and implement everything in this repo while preserving usernames and bootloader settings along with hardware-configuration.nix as it is set during installation(left as is for now).

### scripts/bash/nixbuild.sh
Script set up to read the current machine-name and build accordingly, modify the contents of flake.nix to match any desired setup per device if used with multiple devices. Will run as the "default" option if host-name is not any expected setup of mine from this repo.

### scripts/bash/nixupdate.sh
Script set up to update the current flake to the latest version and then rebuilds the system. Used to update kernel, mostly.

# TODO
[ 1 ] Use writeShellScriptBin to avoid having to link to the above scripts via fish, WIP in configuration.nix

[ 2 ] Build from this directory using flake and avoid linking to /etc/nixos in order to preserve previous Nix-configuration.

