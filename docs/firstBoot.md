# First boot

## Before you run the installer

You need Arch Linux or a derivative with `pacman`, a normal user with sudo, and at least 3 GB free in your home. The repo should be at `~/BlackNode`. The installer will offer to clone it there if it is missing.

```bash
git clone https://github.com/zhaleff/BlackNode.git "$HOME/BlackNode"
cd "$HOME/BlackNode"
bash Scripts/install.sh
```

The installer backs up existing configs to `~/.blacknode-backup-YYYYmmdd-HHMMSS` and writes a log to `~/.blacknode-install.log`. Read the log if a command fails. The retry/skip/abort prompt is part of the design, not an error.

## The first login looks broken

A clean clone does not contain the generated color files. Hyprland loads `~/.config/hypr/themes/colors.lua`, Kitty includes `~/.config/kitty/colors.conf`, Waybar imports `colors.css`, and Hyprlock sources `hyprlang.conf`. None of those files are in git. They appear after `matugen` runs.

The installer links the configs but does not run `matugen`. If you log in before generating the theme, you may get missing colors, a bar with no styling, or a failed Hyprland start.

Generate the theme once:

1. Log in to Hyprland. If the session fails, start Hyprland from a TTY with `Hyprland` and read the error.
2. Open Kitty with `SUPER + D`.
3. Run `~/.config/rofi/scripts/wallselect.sh` or press `SUPER + W`.
4. Pick an image from `~/Pictures/Wallpapers`.

`wallselect.sh` applies the wallpaper with `awww`, copies it to `~/.config/hypr/hyprlock.png`, and runs `matugen image <file> -m <mode> --source-color-index 0`.

If you prefer to generate without the menu:

```bash
mkdir -p ~/Pictures/Wallpapers
matugen image ~/Pictures/Wallpapers/your-wallpaper.jpg -m light --source-color-index 0
```

Use `dark` instead of `light` for a dark palette. The mode is a preference; it does not change the layout or the rest of the desktop.

Then reload the programs that read the generated files:

```bash
hyprctl reload
killall waybar && waybar &
killall dunst && dunst &
pkill -USR1 kitty
pkill -USR1 cava
```

## Packages the installer does not cover

The installer installs the `core` and `aur` groups in `Scripts/install/packages.json`. Several things referenced by the configs are outside those groups:

| Missing package | Used by |
|---|---|
| `network-manager-applet` | `nm-applet` in autostart |
| `bibata-cursor-theme` | `hyprctl setcursor Bibata-Modern-Classic 24` |
| `wf-recorder` | `recordscreen.sh` |
| `pavucontrol` | `SUPER + SHIFT + A` |
| `dolphin` | `SUPER + E` and the window rule |
| `spotify` | `SUPER + Y` and the window rule |
| `python-requests` | Waybar weather script |
| `exa` or `eza` | Zsh aliases and fzf previews |
| `satty` | `screenshots.sh` |
| `mpc`, `amixer` | `powermenu.sh` suspend path |

Install what you use. A missing binary in `autostart.lua` fails silently because `hl.exec_cmd` does not wait for it.

## Checks after install

```bash
# Are the configs symlinked?
ls -l ~/.config/hypr ~/.config/waybar ~/.local/bin/blacknode

# Did the theme generate?
ls -l ~/.config/hypr/themes/colors.lua ~/.config/waybar/colors.css ~/.config/kitty/colors.conf

# Is the session running?
hyprctl version
hyprctl monitors

# Is the bar running?
pgrep -a waybar
```

If `~/.config/hypr` is a real directory and not a symlink, the install did not reach the link step. Run the installer again or link it by hand:

```bash
ln -sfn ~/BlackNode/Configs/.config/hypr ~/.config/hypr
```

Repeat for each directory in `Configs/.config` and each entry in `Configs/.local/bin`.

## When Hyprland will not start

Read the error from a TTY. The usual cause is a missing generated file or a syntax error in a Lua module.

```bash
Hyprland
```

If the config is the problem, move it aside and start with the default, then add modules back:

```bash
mv ~/.config/hypr/hyprland.lua ~/.config/hypr/hyprland.lua.bak
```

For keyboard problems, check `~/.config/hypr/settings/input.lua`. The post-install log is at `~/.blacknode-install.log`.

## After the desktop appears

Set the keyboard layout in `~/.config/hypr/settings/input.lua` if you do not use `us,es`. Check the monitor line in `~/.config/hypr/settings/monitor.lua`; the installer writes one if it can detect the resolution. Pick a wallpaper, then open `SUPER + SPACE` to see the menu. Install the optional packages you actually need.
