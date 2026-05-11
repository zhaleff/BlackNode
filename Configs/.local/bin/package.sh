#!/bin/bash

ASSETS="$HOME/.config/dunst/assets"
THRESHOLD=50

get_updates() {
    local aur=0 official=0
    official=$(checkupdates 2>/dev/null | wc -l)
    command -v yay &>/dev/null && aur=$(yay -Qua 2>/dev/null | wc -l)
    echo $(( official + aur ))
}

TOTAL=$(get_updates)

[[ "$TOTAL" -ge "$THRESHOLD" ]] && \
    dunstify -a "packages" -i "$ASSETS/package.svg" -t 8000 "Updates available — $TOTAL packages"
