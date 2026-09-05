#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

for bin in cliphist wl-copy; do
    command -v "$bin" >/dev/null 2>&1 || { notify-send "Clipboard" "Missing: $bin"; exit 1; }
done

show_history() {
    local list
    list=$(cliphist list 2>/dev/null)
    [ -z "$list" ] && { notify-send "Clipboard" "Clipboard is empty"; main_menu; return; }
    local input=""
    while IFS=$'\t' read -r id content; do
        [ -z "$id" ] && continue
        if [[ "$content" == "binary data"* ]]; then
            input+="󰌾  Image"$'\n'
        else
            local preview
            preview=$(echo "$content" | head -c 60 | tr '\n' ' ')
            input+="${preview}"$'\n'
        fi
    done <<< "$list"
    local selected
    selected=$(printf '%s\n' "  Back" "$input" | rofi -dmenu -theme "$THEME" -p "Clipboard" -l 10)
    [ -z "$selected" ] && main_menu && return
    [[ "$selected" == *"Back" ]] && main_menu && return
    local idx
    idx=$(printf '%s' "$list" | grep -n -F "$selected" | head -1 | cut -d: -f1)
    [ -z "$idx" ] && main_menu && return
    local raw_id
    raw_id=$(printf '%s' "$list" | sed -n "${idx}p" | cut -f1)
    [ -z "$raw_id" ] && main_menu && return
    cliphist decode "$raw_id" 2>/dev/null | wl-copy
    notify-send "Clipboard" "Copied"
    main_menu
}

wipe_clipboard() {
    cliphist wipe 2>/dev/null
    wl-copy -c 2>/dev/null
    notify-send "Clipboard" "Clipboard wiped"
}

main_menu() {
    local choice
    choice=$(printf '%s\n' \
        "  Back" \
        "󰌾  History" \
        "󰍴  Wipe" \
        | rofi -dmenu -theme "$THEME" -p "Clipboard")

    case "$choice" in
        *"Back")    exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"History") show_history ;;
        *"Wipe")    wipe_clipboard ;;
    esac
}

main_menu
