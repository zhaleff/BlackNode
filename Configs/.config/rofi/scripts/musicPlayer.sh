#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu-bottom.rasi"
ERROR_ICON="/tmp/blacknode-icons/error.svg"

music_menu() {
    if ! playerctl status &>/dev/null; then
        notify-send "Music" "No player running" -i "$ERROR_ICON"
        exec bash "$ROFI_DIR/scripts/launcher.sh"
    fi

    local play_icon play_label
    if [[ "$(playerctl status)" == "Playing" ]]; then
        play_icon="󰏤"
        play_label="Pause"
    else
        play_icon=""
        play_label="Play"
    fi

    local choice
    choice=$(printf '%s\n' \
        "󰒮  Previous" \
        "${play_icon}  ${play_label}" \
        "󰒭  Next" \
        "󰒝  Shuffle" \
        | rofi -dmenu -theme "$THEME" -p "Music" -l 4 -theme-str 'window {width: 41%;}')

    case "$choice" in
        *"Pause"|*"Play")  playerctl play-pause; music_menu ;;
        *"Next")           playerctl next; music_menu ;;
        *"Previous")       playerctl previous; music_menu ;;
        *"Shuffle")        playerctl shuffle toggle; music_menu ;;
    esac
}

music_menu
