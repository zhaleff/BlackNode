#!/usr/bin/env bash

dir="$HOME/.config/rofi/styles"
pins_dir="$HOME/.local/share/clipshit/pins"
thumb_dir="/tmp/clipshit-thumbs"
mkdir -p "$pins_dir" "$thumb_dir"

notify() {
    dunstify -h string:x-dunst-stack-tag:clip_notif -t "${2:-2000}" -u "${3:-normal}" "Clipboard" "$1"
}

get_thumb() {
    local id="$1"
    local thumb="$thumb_dir/$id.png"
    [[ -f "$thumb" ]] || cliphist decode "$id" 2>/dev/null > "$thumb"
    echo "$thumb"
}

build_list() {
    for f in "$pins_dir"/*; do
        [[ -e "$f" ]] || continue
        local name
        name=$(basename "$f")
        if file "$f" | grep -qi image; then
            echo -e "pin\t$name\0icon\x1f$f"
        else
            local preview
            preview=$(head -c 80 "$f" | tr '\n' ' ')
            echo -e "pin\t\uf08d  $preview"
        fi
    done

    cliphist list | while IFS=$'\t' read -r id content; do
        if [[ "$content" == "binary data"* ]]; then
            local thumb
            thumb=$(get_thumb "$id")
            echo -e "hist:$id\t\uf03e  Image\0icon\x1f$thumb"
        else
            echo -e "hist:$id\t$content"
        fi
    done
}

copy_entry() {
    local key="$1"
    if [[ "$key" == pin ]]; then
        wl-copy < "$2"
    else
        cliphist decode "${key#hist:}" | wl-copy
    fi
}

delete_entry() {
    local key="$1"
    if [[ "$key" == pin ]]; then
        rm -f "$pins_dir/$2"
    else
        cliphist list | grep "^${key#hist:}"$'\t' | cliphist delete
    fi
}

pin_entry() {
    local key="$1"
    local id="${key#hist:}"
    local target="$pins_dir/pin_$(date +%s%N)"
    cliphist decode "$id" > "$target"
    notify "Pinned" 1500
}

wipe_flow() {
    yes=''
    no=''
    confirmation=$(echo -e "<span foreground='#a6e3a1'>$yes</span>\n<span foreground='#f38ba8'>$no</span>" |
        rofi -markup-rows -dmenu -p 'Confirmation' -mesg 'Are you sure?' -theme "${dir}/clipboard-confirmation.rasi")

    if [[ $confirmation =~ "$yes" ]]; then
        cliphist wipe
        wl-copy -c
        notify "Clipboard has been wiped" 4000 critical
    fi
}

main() {
    if [[ -z $(cliphist list) && -z $(ls -A "$pins_dir" 2>/dev/null) ]]; then
        notify "Clipboard is empty" 4000 critical
        exit
    fi

    local wipe_label=$'\uf1f8   Wipe Clipboard'
    local list
    list=$(build_list)

    local raw
    raw=$(printf "%s\n%s" "$wipe_label" "$list" | rofi -dmenu -markup-rows -show-icons \
        -display-columns 2 -p "Clipboard" \
        -kb-custom-1 "Alt+d" \
        -kb-custom-2 "Alt+p" \
        -theme "${dir}/clipboard-list.rasi")
    local ec=$?

    [[ -z "$raw" ]] && exit

    if [[ "$raw" == *"Wipe Clipboard"* ]]; then
        wipe_flow
        exit
    fi

    local key="${raw%%$'\t'*}"
    local label="${raw#*$'\t'}"

    case $ec in
        0)
            copy_entry "$key" "$label"
            notify "Copied — press Ctrl+V to paste"
            ;;
        10)
            delete_entry "$key" "$label"
            notify "Entry deleted" 1500
            ;;
        11)
            [[ "$key" == pin ]] || pin_entry "$key"
            ;;
    esac
}

main
