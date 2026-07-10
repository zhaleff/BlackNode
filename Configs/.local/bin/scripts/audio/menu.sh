#!/usr/bin/env bash
notify() { notify-send "$1" "$2"; }
ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"

main() {
    local options=(
        "Volume Up"
        "Volume Down"
        "Mute"
        "Change Sink"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Audio" -theme "$ROFI_SUB_THEME")

    case "$choice" in
        "Volume Up") vol_up ;;
        "Volume Down") vol_down ;;
        "Mute") toggle_mute ;;
        "Change Sink") change_sink ;;
    esac
}

vol_up() {
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    notify "Volume" "+5%"
}

vol_down() {
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    notify "Volume" "-5%"
}

toggle_mute() {
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    local muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED" || echo "unmuted")
    notify "Audio" "$muted"
}

change_sink() {
    local sinks=$(wpctl list-sinks | grep -E "^[0-9]" | awk '{print $2}')
    local sel=$(echo "$sinks" | rofi -dmenu -i -p "Sink" -theme "$ROFI_SUB_THEME")
    if [[ -n "$sel" ]]; then
        wpctl set-default-sink "$sel" && notify "Audio" "Sink: $sel"
    fi
}

main