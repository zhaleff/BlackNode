#!/bin/bash

R="$HOME/.config/rofi"
MENU_THEME="$R/shared/menu.rasi"
LIST_THEME="$R/styles/notifications-list.rasi"
RAW="${XDG_RUNTIME_DIR:-/tmp}/notif-raw.json"
IDS="${XDG_RUNTIME_DIR:-/tmp}/notif-ids"

sidebar() {
    local paused=$(dunstctl is-paused)
    [[ "$paused" == "true" ]] && local pause_icon="󰂛 " || local pause_icon="󰂚 "
    local choice
    choice=$(printf "󰅇 \n󰆴 \n${pause_icon}\n󰋼 " | rofi -dmenu -p "Notif" -theme-str "listview { lines: 4; }" -theme "$MENU_THEME")
    case "$choice" in
        "󰅇 ") history ;;
        "󰆴 ") dunstctl history-clear && notify-send "Notifications" "Cleared" && sidebar ;;
        "󰂛 "|"󰂚 ") dunstctl set-paused toggle && sidebar ;;
        "󰋼 ") stats ;;
    esac
}

history() {
    dunstctl history > "$RAW" 2>/dev/null
    > "$IDS"
    local list
    RAW="$RAW" IDS="$IDS" list=$(python3 -c "
import os, json
with open(os.environ['RAW']) as f:
    d = json.load(f)
all_notifs = d.get('data', [])
if not all_notifs:
    exit(0)
notifs = all_notifs[0]
with open(os.environ['IDS'], 'w') as f:
    for n in notifs[-10:]:
        i = n.get('id', {}).get('data', '')
        a = n.get('appname', {}).get('data', '')
        s = n.get('summary', {}).get('data', '')
        b = n.get('body', {}).get('data', '')
        label = a
        if s:
            label += ': ' + s
        if b and len(label) + len(b) < 80:
            label += ' - ' + b
        f.write(str(i) + '\t' + label + '\n')
        print(label)
" 2>/dev/null)
    [[ -z "$list" ]] && notify-send "Notifications" "History is empty" && sidebar && return
    local selected
    selected=$(echo "$list" | rofi -dmenu -p "Notifications" -theme "$LIST_THEME")
    [[ -z "$selected" ]] && sidebar && return
    local id
    id=$(grep -F "$selected" "$IDS" 2>/dev/null | head -1 | cut -d'	' -f1)
    if [[ -n "$id" ]]; then
        local choice
        choice=$(printf "󰅇  Close\n󰋼  Info\n󰈙  Open app" | rofi -dmenu -p "Action" -theme-str "listview { lines: 3; }" -theme "$LIST_THEME")
        case "$choice" in
            "󰅇  Close")
                dunstctl close "$id" && notify-send "Notif" "Closed #$id"
                ;;
            "󰋼  Info")
                RAW="$RAW" python3 -c "
import os, json
with open(os.environ['RAW']) as f:
    d = json.load(f)
id='$id'
for n in d.get('data', [[]])[0]:
    if str(n.get('id', {}).get('data', '')) == id:
        print('App: ' + n.get('appname', {}).get('data', ''))
        print('Summary: ' + n.get('summary', {}).get('data', ''))
        print('Body: ' + n.get('body', {}).get('data', ''))
        print('Urgency: ' + n.get('urgency', {}).get('data', ''))
" | rofi -dmenu -p "Info" -theme-str "listview { lines: 4; }" -theme "$LIST_THEME"
                ;;
            "󰈙  Open app")
                local app
                RAW="$RAW" app=$(python3 -c "
import os, json
with open(os.environ['RAW']) as f:
    d = json.load(f)
id='$id'
for n in d.get('data', [[]])[0]:
    if str(n.get('id', {}).get('data', '')) == id:
        print(n.get('appname', {}).get('data', '').lower())
")
                [[ -n "$app" ]] && notify-send "Notif" "App: $app"
                ;;
        esac
    fi
    history
}

stats() {
    local info
    info=$(python3 -c "
import subprocess
r = subprocess.run(['dunstctl', 'count'], capture_output=True, text=True)
for l in r.stdout.strip().split('\n'):
    if ':' in l:
        k, v = l.split(':', 1)
        print(k.strip() + ': ' + v.strip())
")
    echo "$info" | rofi -dmenu -p "Stats" -theme-str "listview { lines: 3; }" -theme "$LIST_THEME"
    sidebar
}

sidebar
