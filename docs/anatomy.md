# Anatomy of the repo

## What each directory does

| Path | Contents | Installed |
|---|---|---|
| `Configs/.config/` | application dotfiles (`hypr`, `waybar`, `rofi`, `kitty`, `nvim`, and others) | yes, symlinked into `~/.config/` |
| `Configs/.local/bin/` | user scripts (`blacknode/`, `system/`) | yes, symlinked into `~/.local/bin/` |
| `Scripts/` | installer and checks | no, run from the repo |
| `Scripts/install/packages.json` | package groups | read by the installer |
| `version.json` | repo version and a `brain` component version | no |
| `whatnews.json` | changelog fetched from GitHub | no |

The installer walks the first level of `Configs/.config` and creates one symlink per directory. `~/.config/hypr` points at `~/BlackNode/Configs/.config/hypr`, so editing the file in your home edits the repo. The same happens with `~/.local/bin/blacknode` and `~/.local/bin/system`.

## The `~/BlackNode` contract

The installer hardcodes `REPO="${HOME}/BlackNode"`. If the repo is somewhere else, it offers to clone it into `~/BlackNode` and works from there. A few paths also ignore `$HOME` and `$XDG_CONFIG_HOME`:

| File | Fixed path |
|---|---|
| `Configs/.config/rofi/config.rasi` | `@theme "~/BlackNode/Configs/.config/rofi/themes/presets/submenu.rasi"` |
| `Configs/.config/hypr/settings/keybinds.lua` | `~/BlackNode/Configs/.local/bin/system/osd/` |
| `Scripts/install.sh` | `${HOME}/BlackNode` |

If you move the repo, update those paths. The symlink step alone will not fix them.

## The installer

`Scripts/install.sh` is interactive. It checks the distro, `pacman`, internet access, the pacman lock, sudo, the `video` and `input` groups, disk space, GPU, resolution, language, the existing desktop, and whether BlackNode links already exist.

| Flag | Effect |
|---|---|
| `--minimal` | skips optional packages |
| `--nvidia` | accepted but unused; GPU detection decides |
| `--no-nvidia` | skips the NVIDIA setup |
| `--help` | prints the flag list |

The flow is: AUR helper, core packages, AUR packages, optional packages, NVIDIA, keyboard, resolution, shell, wallpaper directory, symlinks, post-install. Package groups live in `Scripts/install/packages.json` (`core`, `aur`, `optional`, `critical`, `nvidia`).

Every command goes through `run()`, which appends to `~/.blacknode-install.log`. On failure it offers retry, skip, or abort. Abort can restore the symlinks from the backup. The backup directory is `~/.blacknode-backup-YYYYmmdd-HHMMSS`. Before linking, each existing file is moved there.

The installer does not run `matugen` and does not create the color files. That happens the first time you pick a wallpaper. Until then, several programs look for files that do not exist. See [firstBoot.md](firstBoot.md).

## Generated files

These files are ignored by git and do not travel in a clean clone:

| Generated file | Produced by | Used by |
|---|---|---|
| `hypr/themes/colors.lua` | matugen | Hyprland |
| `hypr/themes/hyprlang.conf` | matugen | Hyprlock |
| `kitty/colors.conf` | matugen | Kitty |
| `waybar/colors.css` | matugen | Waybar |
| `rofi/colors.rasi` | matugen | Rofi |
| `dunst/dunstrc` | matugen | Dunst |
| `nvim/lua/core/highlights/colors.lua` | matugen | Neovim |
| `~/.cache/matugen/icons.json` | matugen | `recolor-icons.sh` |
| `hypr/hyprlock.png` | `wallselect.sh` | Hyprlock |
| `clipse/blacknode.json` | nothing today | Clipse points at it in `config.json` |

The rest of the outputs are listed in `Configs/.config/matugen/config.toml`, including wlogout, cava, btop, and Alacritty. If you add an app, add its template and its block there, then copy the pattern.

## State and cache

| Path | Stores | Written by |
|---|---|---|
| `~/.local/share/blacknode/whatsnew_seen` | IDs of news already shown | `whatsnews.sh` |
| `~/.local/share/blacknode/theme_mode` | `dark` or `light` | `wallpaper.sh` |
| `~/.cache/hyprlock/weather.json` | lock screen weather | `hypr/scripts/weather.sh` |
| `~/.local/state/waybar/weather_cache.json` | Waybar weather | `waybar/Scripts/weather/script.py` |
| `/tmp/blacknode-icons/` | recolored SVGs | `recolor-icons.sh` |

`/tmp` is cleared on reboot. The icons are regenerated at Hyprland startup. A notification script that runs before that may not find an icon and will show the fallback.
