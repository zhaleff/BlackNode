#!/usr/bin/env bash

count=$(yay -Qua 2>/dev/null | wc -l)

if [ "$count" -eq 0 ]; then
    echo '{"text":"0","tooltip":"No AUR updates","class":"none"}'
    exit 0
fi

tooltip=$(yay -Qua 2>/dev/null | head -n 10 | awk '{print $1}')

jq -nc --arg text "$count" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip, class: "updates"}'
