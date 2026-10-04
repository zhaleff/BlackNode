#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

volume_control() {
    local muted mute_label

    muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)
    mute_label="󰕾  Mute"
    [[ "$muted" -gt 0 ]] && mute_label="󰖁  Unmute"

    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "${mute_label}" \
        "󰓃  Output" \
        "󰏋  Pavucontrol" \
        | rofi -dmenu -theme "$THEME" -p "Audio")

    case "$choice" in
        *"Back")        exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Mute"*)       wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; volume_control ;;
        *"Output")      output_menu ;;
        *"Pavucontrol") pavucontrol & disown ;;
    esac
}

output_menu() {
    local menu_input selected_line
    declare -a sink_ids

    menu_input="󰌍  Back"$'\n'

    while IFS=$'\t' read -r id name; do
        [[ -z "$id" ]] && continue
        sink_ids+=("$id")
        menu_input+="󰓃  ${name}"$'\n'
    done < <(pactl list sinks 2>/dev/null | awk '
        /^Sink #/ { id=$2; gsub(/#/, "", id) }
        /Description:/ { $1=""; sub(/^ /, ""); print id "\t" $0 }
    ')

    [[ ${#sink_ids[@]} -eq 0 ]] && { volume_control; return; }

    selected_line=$(printf '%s' "$menu_input" | rofi -dmenu -theme "$THEME" -p "Output" -format i)
    [[ -z "$selected_line" || "$selected_line" -eq 0 ]] && { volume_control; return; }

    pactl set-default-sink "${sink_ids[$((selected_line - 1))]}"
    volume_control
}

volume_control
