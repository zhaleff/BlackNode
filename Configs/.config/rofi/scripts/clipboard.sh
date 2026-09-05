#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
PINS_DIR="$HOME/.local/share/cliphist/pins"
mkdir -p "$PINS_DIR"

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
    selected=$(printf '%s\n' "󰌍  Back" "$input" | rofi -dmenu -theme "$THEME" -p "Clipboard" -l 10)
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

show_pinned() {
    local pins=""
    for f in "$PINS_DIR"/*; do
        [ -e "$f" ] || continue
        local name
        name=$(basename "$f")
        if file "$f" | grep -qi image; then
            pins+="󰌾  ${name}"$'\n'
        else
            local preview
            preview=$(head -c 60 "$f" | tr '\n' ' ')
            pins+="${preview}"$'\n'
        fi
    done
    [ -z "$pins" ] && { notify-send "Clipboard" "No pinned items"; main_menu; return; }
    local selected
    selected=$(printf '%s\n' "󰌍  Back" "$pins" | rofi -dmenu -theme "$THEME" -p "Pinned" -l 10)
    [ -z "$selected" ] && main_menu && return
    [[ "$selected" == *"Back" ]] && main_menu && return
    local idx=0
    local i=1
    while IFS= read -r line; do
        [ "$line" = "$selected" ] && { idx=$i; break; }
        i=$((i+1))
    done <<< "$pins"
    [ "$idx" -eq 0 ] && main_menu && return
    local pin_file
    pin_file=$(ls "$PINS_DIR"/* 2>/dev/null | sed -n "${idx}p")
    [ -z "$pin_file" ] && main_menu && return
    wl-copy < "$pin_file"
    notify-send "Clipboard" "Copied pinned item"
    main_menu
}

pin_entry() {
    local list
    list=$(cliphist list 2>/dev/null)
    [ -z "$list" ] && { notify-send "Clipboard" "Nothing to pin"; main_menu; return; }
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
    selected=$(printf '%s\n' "󰌍  Back" "$input" | rofi -dmenu -theme "$THEME" -p "Pin Item" -l 10)
    [ -z "$selected" ] && main_menu && return
    [[ "$selected" == *"Back" ]] && main_menu && return
    local idx
    idx=$(printf '%s' "$list" | grep -n -F "$selected" | head -1 | cut -d: -f1)
    [ -z "$idx" ] && main_menu && return
    local raw_id
    raw_id=$(printf '%s' "$list" | sed -n "${idx}p" | cut -f1)
    [ -z "$raw_id" ] && main_menu && return
    local target="$PINS_DIR/pin_$(date +%s%N)"
    cliphist decode "$raw_id" > "$target" 2>/dev/null
    notify-send "Clipboard" "Pinned"
    main_menu
}

delete_history() {
    cliphist wipe 2>/dev/null
    wl-copy -c 2>/dev/null
    notify-send "Clipboard" "History wiped"
}

main_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "󰌾  History" \
        "󰐀  Pinned" \
        "󰏗  Pin Item" \
        "󰍴  Wipe" \
        | rofi -dmenu -theme "$THEME" -p "Clipboard")

    case "$choice" in
        *"Back")       exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"History")    show_history ;;
        *"Pinned")     show_pinned ;;
        *"Pin Item")   pin_entry ;;
        *"Wipe")       delete_history ;;
    esac
}

main_menu
