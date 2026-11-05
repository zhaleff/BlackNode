#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
PINS_DIR="$HOME/.local/share/cliphist/pins"
mkdir -p "$PINS_DIR"

for bin in cliphist wl-copy; do
    command -v "$bin" >/dev/null 2>&1 || { notify-send "Clipboard" "Missing: $bin"; exit 1; }
done

preview_for() {
    if [[ "$1" == "binary data"* ]]; then
        echo "󰌲  Image"
    elif [[ -f "$1" ]]; then
        if file "$1" | grep -qi image; then
            echo "󰌲  $(basename "$1")"
        else
            head -c 60 "$1" | tr '\n' ' '
        fi
    else
        head -c 60 <<< "$1" | tr '\n' ' '
    fi
}

pick_entry() {
    local prompt="$1" empty_msg="$2" source="$3"
    local menu_input selected_line
    declare -a keys

    menu_input="󰌍  Back"$'\n'

    if [[ "$source" == "cliphist" ]]; then
        local list
        list=$(cliphist list 2>/dev/null)
        [[ -z "$list" ]] && { notify-send "Clipboard" "$empty_msg"; return 1; }
        while IFS=$'\t' read -r id content; do
            [[ -z "$id" ]] && continue
            keys+=("$id")
            menu_input+="$(preview_for "$content")"$'\n'
        done <<< "$list"
    else
        for f in "$PINS_DIR"/*; do
            [[ -e "$f" ]] || continue
            keys+=("$f")
            menu_input+="$(preview_for "$f")"$'\n'
        done
        [[ ${#keys[@]} -eq 0 ]] && { notify-send "Clipboard" "$empty_msg"; return 1; }
    fi

    selected_line=$(printf '%s' "$menu_input" | rofi -dmenu -theme "$THEME" -p "$prompt" -l 10 -format i)
    [[ -z "$selected_line" || "$selected_line" -eq 0 ]] && return 1

    echo "${keys[$((selected_line - 1))]}"
}

show_history() {
    local id
    id=$(pick_entry "Clipboard" "Clipboard is empty" "cliphist") || { main_menu; return; }
    cliphist decode "$id" 2>/dev/null | wl-copy
    notify-send "Clipboard" "Copied"
    main_menu
}

pin_entry() {
    local id
    id=$(pick_entry "Pin Item" "Nothing to pin" "cliphist") || { main_menu; return; }
    cliphist decode "$id" > "$PINS_DIR/pin_$(date +%s%N)" 2>/dev/null
    notify-send "Clipboard" "Pinned"
    main_menu
}

show_pinned() {
    local file
    file=$(pick_entry "Pinned" "No pinned items" "pins") || { main_menu; return; }
    wl-copy < "$file"
    notify-send "Clipboard" "Copied pinned item"
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
        "  History" \
        "󰐃  Pinned" \
        "󰐃  Pin Item" \
        "󰚃  Wipe" \
        | rofi -dmenu -theme "$THEME" -p "Clipboard")

    case "$choice" in
        *"Back")     exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"History")  show_history ;;
        *"Pinned")   show_pinned ;;
        *"Pin Item") pin_entry ;;
        *"Wipe")     delete_history ;;
    esac
}

main_menu
