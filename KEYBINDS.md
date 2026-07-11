# Keybindings

All keybinds use the `SUPER` key (Windows key) as the primary modifier. Application paths are defined in `~/.config/hypr/settings/programs.lua` (or `keybinds.lua`).

## Window Management

| Key | Action |
|-----|--------|
| `SUPER + Q` | Kill active window |
| `SUPER + F` | Toggle floating/tiling |
| `SUPER + P` | Toggle pseudo-tiling |
| `SUPER + J` | Toggle split orientation |
| `SUPER + SHIFT + F` | Fullscreen |

## Focus & Navigation

| Key | Action |
|-----|--------|
| `SUPER + arrow` | Move focus (left/right/up/down) |
| `SUPER + 1–0` | Switch to workspace 1–10 |
| `SUPER + SHIFT + 1–0` | Move window to workspace 1–10 |
| `SUPER + S` | Toggle special workspace (scratchpad) |
| `SUPER + SHIFT + S` | Move window to special workspace |

## Applications

| Key | Action |
|-----|--------|
| `SUPER + D` | Terminal (Kitty) |
| `SUPER + B` | Browser |
| `SUPER + E` | File manager |
| `SUPER + Y` | Music player (Spotify) |
| `SUPER + R` | Rofi launcher (bn-menu) |
| `SUPER + C` | Clipboard manager (clipse) |
| `SUPER + H` | Screenshot (hyprshot) |
| `SUPER + L` | Lock screen (hyprlock) |
| `SUPER + W` | Wallpaper selector (swww) |
| `SUPER + SHIFT + X` | Logout menu (wlogout) |
| `SUPER + SPACE` | bn-menu main hub |

## Rofi Sidebars

| Key | Action |
|-----|--------|
| `SUPER + A` | Wi-Fi menu |
| `SUPER + B` | Bluetooth menu |
| `SUPER + N` | Notifications |
| `SUPER + SHIFT + A` | Audio controller |
| `SUPER + SHIFT + N` | Notes |
| `SUPER + SHIFT + F` | Search |
| `SUPER + SHIFT + K` | Keyboard layout |
| `SUPER + SHIFT + I` | Config HUD |
| `SUPER + SHIFT + O` | Dashboard |

## Media Keys

| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up (`wpctl`) |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Brightness up (`brightnessctl`) |
| `XF86MonBrightnessDown` | Brightness down |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `XF86AudioPlay` / `XF86AudioPause` | Play/pause (`playerctl`) |

## Mouse

| Key | Action |
|-----|--------|
| `SUPER + left click` | Move window |
| `SUPER + right click` | Resize window |
| `SUPER + scroll` | Switch workspace |

## Dashboard

Dashboard is a quickshell window (820x680, floating, centred). Triggered by `SUPER + SHIFT + O`. Shows git stats, system metrics, and activity timeline.
