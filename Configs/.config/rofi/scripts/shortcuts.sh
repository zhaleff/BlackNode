#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

declare -A actions=(
    ["SUPER + B  →  Firefox"]="firefox"
    ["SUPER + D  →  Kitty"]="kitty"
    ["SUPER + E  →  Dolphin"]="dolphin"
    ["SUPER + Y  →  Spotify"]="spotify"
    ["SUPER + SPACE  →  BlackNode menu"]="bash ~/.config/rofi/scripts/launcher.sh"
    ["SUPER + R  →  App launcher"]="rofi -show drun"
    ["SUPER + T  →  Music player menu"]="~/.config/rofi/scripts/musicPlayer.sh"
    ["SUPER + SHIFT + X  →  Power menu"]="~/.config/rofi/scripts/powermenu.sh"
    ["SUPER + H  →  Screenshots"]="~/.config/rofi/scripts/screenshots.sh"
    ["SUPER + W  →  Wallpaper select"]="~/.config/rofi/scripts/wallselect.sh"
    ["SUPER + V  →  Clipboard"]="~/.config/rofi/scripts/clipboard.sh"
    ["SUPER + SHIFT + H  →  Screen recorder"]="~/.config/rofi/scripts/recordscreen.sh"
    ["SUPER + SHIFT + I  →  Theme select"]="~/.config/rofi/scripts/themeselect.sh"
    ["SUPER + SHIFT + A  →  Pavucontrol"]="pavucontrol"
    ["SUPER + SHIFT + K  →  Keyboard layout"]="~/.config/rofi/scripts/keyboardlayout.sh"
    ["SUPER + SHIFT + D  →  Do Not Disturb"]="~/.config/rofi/scripts/dnd.sh"
    ["SUPER + SHIFT + B  →  Bookmarks"]="~/.config/rofi/scripts/bookmarks.sh"
    ["SUPER + X  →  Logout menu"]="wlogout -b 6"
    ["SUPER + L  →  Lock screen"]="hyprlock"
)

choice=$(printf '%s\n' "${!actions[@]}" | sort | rofi -dmenu -theme "$THEME" -p "Keybinds")
[ -z "$choice" ] && exit 0

cmd="${actions[$choice]}"
eval "$cmd" & disown
