#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

volume_control() {
    local vol muted mic_icon
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')
    muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)

    local mic_muted
    mic_muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -c MUTED)
    [ "$mic_muted" -gt 0 ] && mic_icon="" || mic_icon="󰍭"

    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰕾  Mute" \
        "󰝝  +10%" \
        "󰝞  -10%" \
        "󰝚  Apps" \
        "$mic_icon  Mic" \
        | rofi -dmenu -theme "$THEME" -p "Audio")

    case "$choice" in
        *"Back")    exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"Mute")    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; volume_control ;;
        *"+10%")    wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+; volume_control ;;
        *"-10%")    wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-; volume_control ;;
        *"Apps")
            local list=""
            while IFS= read -r block; do
                local id name mute icon
                id=$(echo "$block" | awk '/^Sink Input/ {gsub(/.*#/, "", $3); print $3}')
                name=$(echo "$block" | awk -F'"' '/application.name/ {print $2}')
                mute=$(echo "$block" | awk '/Mute:/ {print $2}')
                [ -z "$name" ] && continue
                icon="󰝚"
                [ "$mute" = "yes" ] && icon="󰝟"
                list="${list}${icon}  ${name} (${id})"$'\n'
            done < <(pactl list sink-inputs 2>/dev/null | sed -n '/Sink Input/,/^$/p')
            [ -z "$list" ] && { notify-send "Audio" "No active apps"; volume_control; return; }
            local selected
            selected=$(printf '%s\n' "󰌍  Back" "$list" | rofi -dmenu -theme "$THEME" -p "Apps")
            [ -z "$selected" ] && volume_control && return
            [[ "$selected" == *"Back" ]] && volume_control && return
            local app_id
            app_id=$(echo "$selected" | sed 's/.*(\([0-9]*\)).*/\1/')
            [ -n "$app_id" ] && pactl set-sink-input-mute "$app_id" toggle && volume_control
            ;;
        *"Mic")    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle; volume_control ;;
    esac
}

volume_control
