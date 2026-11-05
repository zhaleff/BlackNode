#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
MONITOR_LUA="$HOME/.config/hypr/settings/monitor.lua"

BACK="󰌍  Back"

monitors_json() { hyprctl monitors all -j 2>/dev/null; }

apply() {
    local out
    out=$(hyprctl keyword monitor "$1" 2>&1)
    [[ "$out" == "ok" ]] || notify-send "Monitors" "${out:-Failed to apply: $1}"
}

active_count() {
    monitors_json | jq '[.[] | select(.disabled | not)] | length'
}

# name,mode keeping current position and scale
apply_mode() {
    local name="$1" mode="$2" x y scale
    read -r x y scale < <(monitors_json | jq -r --arg n "$name" \
        '.[] | select(.name == $n) | "\(.x) \(.y) \(.scale)"')
    apply "${name},${mode},${x}x${y},${scale}"
}

max_mode() {
    monitors_json | jq -r --arg n "$1" '
        .[] | select(.name == $n) | .availableModes
        | map(capture("(?<w>\\d+)x(?<h>\\d+)@(?<r>[\\d.]+)Hz")
              | {w: (.w | tonumber), h: (.h | tonumber), r: (.r | tonumber)})
        | sort_by(.w * .h, .r) | last
        | "\(.w)x\(.h)@\(.r)"'
}

refresh_menu() {
    local name="$1" res cur choice mode
    read -r res cur < <(monitors_json | jq -r --arg n "$name" \
        '.[] | select(.name == $n) | "\(.width)x\(.height) \(.refreshRate | round)"')

    local list
    list=$(monitors_json | jq -r --arg n "$name" --arg r "$res" '
        .[] | select(.name == $n) | .availableModes[]
        | select(startswith($r + "@")) | sub("^.*@"; "") | sub("Hz$"; "")' \
        | sort -rnu)

    local input="${BACK}"$'\n'
    while read -r hz; do
        [[ -z "$hz" ]] && continue
        local mark="  "
        [[ "$(printf '%.0f' "$hz")" == "$cur" ]] && mark="󰄬  "
        input+="${mark}${hz}Hz"$'\n'
    done <<< "$list"

    choice=$(printf '%s' "$input" | rofi -dmenu -theme "$THEME" -p "Refresh Rate")
    [[ -z "$choice" || "$choice" == *"Back" ]] && { monitor_menu "$name"; return; }

    mode="${res}@$(sed -E 's/^[^0-9]*([0-9.]+)Hz$/\1/' <<< "$choice")"
    apply_mode "$name" "$mode"
    monitor_menu "$name"
}

monitor_menu() {
    local name="$1" disabled toggle choice
    disabled=$(monitors_json | jq -r --arg n "$name" '.[] | select(.name == $n) | .disabled')

    if [[ "$disabled" == "true" ]]; then
        choice=$(printf '%s\n' "$BACK" "󰍹  Connect" \
            | rofi -dmenu -theme "$THEME" -p "$name")
        case "$choice" in
            *"Back")    list_menu ;;
            *"Connect") apply "${name},preferred,auto,auto"; list_menu ;;
        esac
        return
    fi

    choice=$(printf '%s\n' \
        "$BACK" \
        "󰍹  Max Quality" \
        "󰑓  Auto" \
        "󰓅  Refresh Rate" \
        "󰍺  Disconnect" \
        "  Open monitor.lua" \
        | rofi -dmenu -theme "$THEME" -p "$name")

    case "$choice" in
        *"Back")        list_menu ;;
        *"Max Quality") apply_mode "$name" "$(max_mode "$name")"; monitor_menu "$name" ;;
        *"Auto")        apply "${name},preferred,auto,auto"; monitor_menu "$name" ;;
        *"Refresh Rate") refresh_menu "$name" ;;
        *"Disconnect")
            if [[ "$(active_count)" -le 1 ]]; then
                notify-send "Monitors" "Can't disconnect the only active monitor"
                monitor_menu "$name"
            else
                apply "${name},disable"
                list_menu
            fi ;;
        *"monitor.lua") kitty nvim "$MONITOR_LUA" & disown ;;
    esac
}

list_menu() {
    local input="${BACK}"$'\n' choice
    local -a names=()

    while IFS=$'\t' read -r name w h r disabled; do
        [[ -z "$name" ]] && continue
        names+=("$name")
        if [[ "$disabled" == "true" ]]; then
            input+="󰶐  ${name}  off"$'\n'
        else
            input+="󰍹  ${name}  ${w}x${h}@$(printf '%.0f' "$r")Hz"$'\n'
        fi
    done < <(monitors_json | jq -r '.[] | [.name, .width, .height, .refreshRate, .disabled] | @tsv')

    choice=$(printf '%s' "$input" | rofi -dmenu -theme "$THEME" -p "Monitors" -format i)

    [[ -z "$choice" ]] && exit 0
    [[ "$choice" -eq 0 ]] && exec bash "$ROFI_DIR/scripts/launcher.sh"

    monitor_menu "${names[$((choice - 1))]}"
}

list_menu
