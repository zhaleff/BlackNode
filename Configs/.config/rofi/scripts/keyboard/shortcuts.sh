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
    ["SUPER + M  →  Music player menu"]="~/.config/rofi/scripts/audio/musicPlayer.sh"
    ["SUPER + X  →  Power menu (rofi)"]="~/.config/rofi/scripts/system/powermenu.sh"
    ["SUPER + SHIFT + X  →  Power menu (wlogout)"]="wlogout -b 6"
    ["SUPER + SHIFT + S  →  Screenshots"]="~/.config/rofi/scripts/recording/screenshots.sh"
    ["SUPER + G  →  Screen recorder"]="~/.config/rofi/scripts/recording/recordscreen.sh"
    ["SUPER + W  →  Wallpaper select"]="~/.config/rofi/scripts/appearance/wallselect.sh"
    ["SUPER + V  →  Clipboard"]="~/.config/rofi/scripts/utilities/clipboard.sh"
    ["SUPER + SHIFT + A  →  Pavucontrol"]="pavucontrol"
    ["SUPER + ESCAPE  →  Lock screen"]="hyprlock"
)

choice=$(printf '%s\n' "${!actions[@]}" | sort | rofi -dmenu -theme "$THEME" -p "Keybinds")
[[ -z "$choice" ]] && exit 0

cmd="${actions[$choice]}"
eval "$cmd" & disown
