#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

music_menu() {
    if ! playerctl status &>/dev/null; then
        notify-send "Music" "No player running"
        exec bash "$ROFI_DIR/scripts/launcher.sh"
    fi

    local title artist status_icon art_url art_path
    title=$(playerctl metadata title 2>/dev/null)
    artist=$(playerctl metadata artist 2>/dev/null)
    status_icon=$([ "$(playerctl status)" = "Playing" ] && echo "" || echo "")

    art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)
    art_path="/tmp/blacknode-music-cover"
    if [ -n "$art_url" ]; then
        curl -s -L "$art_url" -o "$art_path" 2>/dev/null
    fi

    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "$status_icon  $title - $artist" \
        "  Play/Pause" \
        "  Next" \
        "  Previous" \
        "  Repeat" \
        | rofi -dmenu -theme "$THEME" -p "Music")

    case "$choice" in
        *"Back")
            exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"$title"*)
            notify-send -i "$art_path" "$title" "$artist"
            music_menu ;;
        *"Play/Pause")   playerctl play-pause; music_menu ;;
        *"Next")         playerctl next; music_menu ;;
        *"Previous")     playerctl previous; music_menu ;;
        *"Repeat")       playerctl shuffle toggle; music_menu ;;
    esac
}

music_menu
