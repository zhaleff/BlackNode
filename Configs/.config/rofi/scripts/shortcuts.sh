#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

declare -A actions=(
    ["󰌍  Back"]="$ROFI_DIR/scripts/launcher.sh"
    ["SUPER + B  →  Firefox"]="firefox"
    ["SUPER + D  →  Kitty"]="kitty"
    ["SUPER + E  →  Dolphin"]="dolphin"
    ["SUPER + Y  →  Spotify"]="spotify"
    ["SUPER + SPACE  →  BlackNode menu"]="bash ~/.config/rofi/scripts/launcher.sh"
    ["SUPER + R  →  App launcher"]="rofi -show drun"
    ["SUPER + K  →  Music player menu"]="~/.config/rofi/scripts/musicPlayer.sh"
    ["SUPER + X  →  Power menu (rofi)"]="~/.config/rofi/scripts/powermenu.sh"
    ["SUPER + SHIFT + X  →  Power menu (wlogout)"]="wlogout -b 6"
    ["SUPER + H  →  Screenshots"]="~/.config/rofi/scripts/screenshots.sh"
    ["SUPER + SHIFT + H  →  Screen recorder"]="~/.config/rofi/scripts/recordscreen.sh"
    ["SUPER + W  →  Wallpaper select"]="~/.config/rofi/scripts/wallselect.sh"
    ["SUPER + V  →  Clipboard"]="~/.config/rofi/scripts/clipboard.sh"
    ["SUPER + SHIFT + A  →  Pavucontrol"]="pavucontrol"
    ["SUPER + L  →  Lock screen"]="hyprlock"
)

choice=$(printf '%s\n' "${!actions[@]}" | sort | rofi -dmenu -theme "$THEME" -p "Keybinds")
[[ -z "$choice" ]] && exit 0

cmd="${actions[$choice]}"
eval "$cmd" & disown
