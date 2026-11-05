

#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

output_menu() {
    local ids=() labels=() id name idx

    while IFS=$'\t' read -r id name; do
        ids+=("$id")
        labels+=("󰓃  $name")
    done < <(pactl list sinks | awk '
        /^Sink #/ { id = substr($2, 2) }
        /Description:/ { sub(/^[ \t]*Description: /, ""); print id "\t" $0 }
    ')

    idx=$(printf '%s\n' "󰌍  Back" "${labels[@]}" | rofi -dmenu -theme "$THEME" -p "Output" -format i)
    [[ -n "$idx" && "$idx" -gt 0 ]] || { volume_control; return; }

    pactl set-default-sink "${ids[idx-1]}"
    volume_control
}

volume_control() {
    local idx mute_label mic_label

    mute_label="󰖁  Mute"
    mic_label="󰍭  Mute mic"
    [[ $(wpctl get-volume @DEFAULT_AUDIO_SINK@) == *MUTED* ]] && mute_label="󰕾  Unmute"
    [[ $(wpctl get-volume @DEFAULT_AUDIO_SOURCE@) == *MUTED* ]] && mic_label="󰍬  Unmute mic"

    idx=$(printf '%s\n' \
        "󰌍  Back" \
        "$mute_label" \
        "$mic_label" \
        "󰓃  Output" \
        "󰏋  Pavucontrol" \
        | rofi -dmenu -theme "$THEME" -p "Audio" -format i)

    case "$idx" in
        0) exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        1) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; volume_control ;;
        2) wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle; volume_control ;;
        3) output_menu ;;
        4) pavucontrol & disown ;;
    esac
}

volume_control
