#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
REPO="$HOME/BlackNode"
RAW_URL="https://raw.githubusercontent.com/zhaleff/BlackNode/main"

menu() { rofi -dmenu -theme "$THEME" "$@"; }

check_updates() {
    local local_hash remote_hash
    local_hash=$(git -C "$REPO" rev-parse HEAD 2>/dev/null)
    remote_hash=$(timeout 8 git -C "$REPO" ls-remote origin main 2>/dev/null | cut -f1)

    if [[ -z "$remote_hash" ]]; then
        notify-send "BlackNode" "Could not reach GitHub"
    elif [[ "$local_hash" == "$remote_hash" ]]; then
        notify-send "BlackNode" "You are up to date"
    else
        notify-send "BlackNode" "Update available. Run: git -C ~/BlackNode pull"
    fi
}

whats_new() {
    local json sel
    json=$(curl -fsS --max-time 8 "$RAW_URL/whatnews.json" \
        | jq -c '[.entries | sort_by(.date) | reverse | .[:10][]]' 2>/dev/null)

    if [[ -z "$json" || "$json" == "[]" ]]; then
        notify-send "BlackNode" "Could not load What's New"
        return
    fi

    sel=$({
        echo "󰌍  Back"
        jq -r '.[] | "󰋽  \(.date)  \(.title)"' <<< "$json"
    } | menu -p "What's New" -l 10 -format i)

    [[ -z "$sel" || "$sel" -eq 0 ]] && return
    notify-send "$(jq -r ".[$((sel - 1))].title" <<< "$json")" \
                "$(jq -r ".[$((sel - 1))].body" <<< "$json")"
}

choice=$(printf '%s\n' \
    "󰌍  Back" \
    "󰚰  Check for updates" \
    "󰋚  What's New" \
    | menu -p "Update")

case "$choice" in
    *"Back")             exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
    *"Check for updates") check_updates ;;
    *"What's New")       whats_new ;;
esac
