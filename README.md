# NixOS Dotfiles

Personal dotfiles repository for managing multiple NixOS systems with a focus on pentesting tools, customization, and efficient workflow.

## Features

- Flake-based NixOS configuration split into focused modules
- Automated color scheme management with pywal
- Multi-monitor support with semi-automatic resolution detection
- Integrated pentesting tools and environment
- Custom lockscreen with blur effect
- Polybar with dynamic workspace handling
- Zathura PDF reader with theme integration
- Custom startpage for browser homepage
- Tailscale VPN integration
- Multi-device support (Razer, ASUS, VM configurations)
- OpenRGB integration for device lighting

## Key Components

- **Window Manager**: i3-gaps with custom keybindings
- **Terminal**: Alacritty with adaptive config based on resolution
- **Shell**: ZSH with custom configuration
- **Bar**: Polybar with dynamic modules
- **Compositor**: Picom for transparency and effects
- **Browser**: Firefox/Librewolf with custom startpage

## Installation

1. Enter a temporary environment with required tools:
```bash
nix-shell -p git python3
```

2. Clone the repository:
```bash
cd && git clone https://github.com/borttappat/dotfiles
```

3. Run the setup script:
```bash
cd dotfiles/scripts/bash
chmod +x nixsetup.sh
./nixsetup.sh
```

The script will:
- Back up your current configuration
- Configure system settings while preserving hardware configuration
- Set up necessary symlinks
- Build and activate the new configuration

## Important Usage Notes

- Initial login is to TTY; use `x` to start X server
- Default keyboard layout is Swedish (configurable in configuration.nix)
- System detects hardware and applies appropriate configuration (Razer/ASUS/VM)
- Color schemes automatically adapt based on wallpaper

## Key Scripts

- `nixsetup.sh`: Initial system configuration and setup
- `nixbuild.sh`: Hardware-aware system rebuild
- `nixupdate.sh`: Update flake and rebuild system
- `lock.sh`: Blur-effect screen locker
- `randomwalrgb.sh`: Random wallpaper with RGB sync
- `walrgb.sh`: Set wallpaper and sync RGB lighting
- `zathuracolors.sh`: Update PDF reader theme

## Keybindings

### Terminal & Applications
| Keybind | Function |
|---------|----------|
| Super + Return | Launch Alacritty |
| Super + S | Launch floating Alacritty |
| Super + b | Launch default browser |
| Super + a | Launch Claude AI in browser |
| Super + Shift + m | Launch YouTube Music |
| Super + z | Launch Zathura |
| Super + d | Launch Rofi |
| Super + Shift + d | Launch Rofi run prompt |

### Window Management
| Keybind | Function |
|---------|----------|
| Super + h/j/k/l | Focus left/down/up/right |
| Super + Shift + h/j/k/l | Move window left/down/up/right |
| Super + c | Split horizontal |
| Super + v | Split vertical |
| Super + f | Toggle fullscreen |
| Super + q | Kill focused window |
| Super + space | Toggle floating |
| Super + Shift + space | Toggle focus between tiling/floating |
| Super + r | Enter resize mode |
| Super + m | Enter move mode for floating windows |

### Workspace Control
| Keybind | Function |
|---------|----------|
| Super + (1-0) | Switch to workspace 1-10 |
| Super + Shift + (1-0) | Move container to workspace 1-10 |

### System Controls
| Keybind | Function |
|---------|----------|
| Super + F1 | Mute audio |
| Super + F2 | Volume down |
| Super + F3 | Volume up |
| Super + F7 | Brightness down |
| Super + F8 | Brightness up |
| Super + Shift + e | Lock screen |
| Super + Shift + s | System suspend |

### Configuration & Monitoring
| Keybind | Function |
|---------|----------|
| Super + Shift + i | Edit i3 config |
| Super + Shift + p | Edit polybar config |
| Super + Shift + n | Edit NixOS packages |
| Super + Shift + c | Edit NixOS config |
| Super + Shift + u | Launch htop |
| Super + Shift + b | Launch bottom |
| Super + p | Restart polybar |

## Useful Aliases

- `nb`: Build system with hardware detection
- `nu`: Update flake and rebuild system
- `np`: Edit package configuration
- `npp`: Edit pentesting tools configuration
- `pc`: Edit Picom config
- `ac`: Edit Alacritty config

## Important Notes

- System builds using only git-tracked files
- After updates, run `nixsetup.sh` before rebuilding
- Back up personal changes before pulling updates
- VM environments may need to disable Picom (`killall picom`)

## Structure

```
dotfiles/
├── modules/         # NixOS configuration modules
├── scripts/
│   ├── bash/       # System management scripts
│   └── python/     # Configuration tooling
├── config/         # Application configs
└── misc/          # Additional resources
```

## Contributing

Feel free to submit issues and pull requests for improvements or bug fixes.

