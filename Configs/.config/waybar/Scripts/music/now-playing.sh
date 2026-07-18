#!/usr/bin/env bash
set -euo pipefail

IFS='|' read -r title artist album arturl < <(playerctl metadata --format "{{title}}|{{artist}}|{{album}}|{{mpris:artUrl}}" 2>/dev/null)
[[ -z "$title" ]] && exit 0

cover=""
if [[ -n "$arturl" ]]; then
    if [[ "$arturl" == file://* ]]; then
        cover="${arturl#file://}"
    else
        cover="/tmp/blacknode-cover.jpg"
        curl -sL "$arturl" -o "$cover" 2>/dev/null || cover=""
    fi
fi

if [[ -n "$cover" && -f "$cover" ]]; then
    dunstify -i "$cover" -t 5000 "$title" "$artist — $album"
else
    dunstify -t 5000 "$title" "$artist — $album"
fi
