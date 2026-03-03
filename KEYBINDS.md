<h1 align="center">Hyprcraft Keybindings</h1>

<div align="center">
  <p>
    <a href="#"><img src="https://img.shields.io/badge/keybinds-52-blue?style=for-the-badge&logo=hyprland&logoColor=white&labelColor=302D41&color=89B4FA" alt="Keybinds"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/last%20updated-2025--03--02-green?style=for-the-badge&logo=github&logoColor=white&labelColor=302D41&color=A6E3A1" alt="Last Updated"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge&logo=open-source-initiative&logoColor=white&labelColor=302D41&color=F9E2AF" alt="License"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/Hyprland-0.41+-brightgreen?style=for-the-badge&logo=linux&logoColor=white&labelColor=302D41&color=CBA6F7" alt="Hyprland"></a>
  </p>
</div>

Hello.  This document outlines every keybinding used in my Hyprland configuration.  The bindings are designed for efficiency, with the `SUPER` key (Windows key) as the primary modifier.  All application paths are sourced from `~/.config/hypr/settings/programs.conf`, allowing easy customisation without touching the main keybind file.

---

## Table of Contents
- [General Window Management](#general-window-management)
- [Application & Tool Launchers](#application--tool-launchers)
- [Focus Movement](#focus-movement)
- [Workspace Switching](#workspace-switching)
- [Moving Windows to Workspaces](#moving-windows-to-workspaces)
- [Special Workspace](#special-workspace)
- [Mouse Bindings](#mouse-bindings)
- [Multimedia Keys](#multimedia-keys)
- [Script‑based Bindings](#scriptbased-bindings)

---

## General Window Management

Basic operations for controlling windows and the compositor.

| Key | Action | Description |
|-----|--------|-------------|
| `SUPER + D` | `exec, $terminal` | Open default terminal |
| `SUPER + Q` | `killactive` | Close active window |
| `SUPER + P` | `pseudo` | Toggle pseudo‑tiling for current window |
| `SUPER + J` | `togglesplit` | Toggle split orientation |
| `SUPER + SHIFT + F` | `fullscreen` | Toggle fullscreen mode |
| `SUPER + F` | `togglefloating` | Toggle floating/tiling state |

---

## Application & Tool Launchers

Quick access to commonly used applications and system tools.

| Key | Action | Description |
|-----|--------|-------------|
| `SUPER + SHIFT + Q` | `exec, ~/.local/bin/suspend.sh` | Suspend system |
| `CTRL + ALT + Up` | `exec, $launch` | Application launcher (defined in programs.conf) |
| `SUPER + SHIFT + D` | `exec, ~/.local/bin/dnd.sh` | Toggle Do Not Disturb |
| `SUPER + SHIFT + X` | `exec, $logout` | Logout menu |
| `SUPER + W` | `exec, $wallselect` | Wallpaper selector |
| `SUPER + C` | `exec, kitty --class clipse -e clipse` | Open clipse (clipboard manager) |
| `SUPER + B` | `exec, $browser` | Default web browser |
| `SUPER + Y` | `exec, $music` | Music player |
| `SUPER + SHIFT + Y` | `exec, $music-p` | Music player (playlist view?) |
| `SUPER + R` | `exec, $launcher` | Application launcher (alternative) |
| `SUPER + SHIFT + C` | `exec, $clipboard` | Clipboard manager |
| `SUPER + H` | `exec, $screenshot` | Screenshot tool |
| `SUPER + A` | `exec, $wifi` | Wi‑Fi menu |
| `SUPER + E` | `exec, $fileManager` | File manager |
| `SUPER + L` | `exec, $lock` | Lock screen |
| `SUPER + X` | `exec, $logout-w` | Logout (alternative) |
| `SUPER + SHIFT + A` | `exec, $audio` | Audio settings |
| `SUPER + SHIFT + I` | `exec, $animation` | Animation settings |

---

## Focus Movement

Navigate between windows using arrow keys.

| Key | Action | Description |
|-----|--------|-------------|
| `SUPER + Left` | `movefocus, l` | Move focus left |
| `SUPER + Right` | `movefocus, r` | Move focus right |
| `SUPER + Up` | `movefocus, u` | Move focus up |
| `SUPER + Down` | `movefocus, d` | Move focus down |

---

## Workspace Switching

Switch between workspaces with `SUPER + number`.

| Key | Action | Workspace |
|-----|--------|-----------|
| `SUPER + 1` … `SUPER + 9` | `workspace, 1` … `workspace, 9` | Workspaces 1–9 |
| `SUPER + 0` | `workspace, 10` | Workspace 10 |

---

## Moving Windows to Workspaces

Move the active window to a specific workspace.

| Key | Action | Destination |
|-----|--------|-------------|
| `SUPER + SHIFT + 1` … `SUPER + SHIFT + 9` | `movetoworkspace, 1` … `movetoworkspace, 9` | Workspaces 1–9 |
| `SUPER + SHIFT + 0` | `movetoworkspace, 10` | Workspace 10 |

---

## Special Workspace

The “magic” scratchpad workspace.

| Key | Action | Description |
|-----|--------|-------------|
| `SUPER + S` | `togglespecialworkspace, magic` | Toggle special workspace “magic” |
| `SUPER + SHIFT + S` | `movetoworkspace, special:magic` | Move window to special workspace |

---

## Mouse Bindings

Resize and move windows with mouse.

| Key | Action | Description |
|-----|--------|-------------|
| `SUPER + mouse:272` | `movewindow` | Move window (left button drag) |
| `SUPER + mouse:273` | `resizewindow` | Resize window (right button drag) |
| `SUPER + mouse_down` | `workspace, e+1` | Switch to next workspace (scroll down) |
| `SUPER + mouse_up` | `workspace, e-1` | Switch to previous workspace (scroll up) |

---

## Multimedia Keys

Hardware keys for volume, brightness, and media control.

| Key | Action | Description |
|-----|--------|-------------|
| `XF86AudioRaiseVolume` | `exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+` | Increase volume |
| `XF86AudioLowerVolume` | `exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-` | Decrease volume |
| `XF86AudioMute` | `exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle` | Toggle mute |
| `XF86AudioMicMute` | `exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle` | Toggle microphone mute |
| `XF86MonBrightnessUp` | `exec, brightnessctl s 10%+` | Increase brightness |
| `XF86MonBrightnessDown` | `exec, brightnessctl s 10%-` | Decrease brightness |
| `XF86AudioNext` | `exec, playerctl next` | Next track |
| `XF86AudioPause` | `exec, playerctl play-pause` | Play/pause |
| `XF86AudioPlay` | `exec, playerctl play-pause` | Play/pause |
| `XF86AudioPrev` | `exec, playerctl previous` | Previous track |

---

## Script‑based Bindings

Enhanced bindings that also trigger notification scripts.

| Key | Action | Description |
|-----|--------|-------------|
| `XF86MonBrightnessDown` | `exec, brightnessctl set 2%- && ~/.local/bin/brightness.sh` | Decrease brightness + notification |
| `XF86MonBrightnessUp` | `exec, brightnessctl set +2% && ~/.local/bin/brightness.sh` | Increase brightness + notification |
| `XF86AudioRaiseVolume` | `exec, pamixer -i 2 && ~/.local/bin/volume.sh` | Increase volume + notification |
| `XF86AudioLowerVolume` | `exec, pamixer -d 2 && ~/.local/bin/volume.sh` | Decrease volume + notification |
| `XF86AudioMute` | `exec, pamixer -t && dunstify …` | Toggle mute with dunst notification |

---

## Notes

- All application variables (`$terminal`, `$browser`, etc.) are defined in `~/.config/hypr/settings/programs.conf`.  Adjust that file to change which programs are launched.
- The script paths (`~/.local/bin/`) assume you have placed custom scripts there.  Ensure they are executable.
- This configuration is part of the [Hyprcraft](https://github.com/zephardev/hyprcraft) project and is subject to continuous refinement.

If you have suggestions or find any issues, feel free to contribute or open an issue on the repository.

**— HollowSec**
