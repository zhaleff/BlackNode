#!/bin/bash

STYLE="$HOME/.config/rofi/styles/kb-layout.rasi"

DEVICE=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .name' | head -1)
CURRENT=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -1)

if echo "$CURRENT" | grep -qi "spanish\|es"; then
    OPTIONS="ENGLISH\nSPANISH"
else
    OPTIONS="SPANISH\nENGLISH"
fi

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "󰌌" -theme "$STYLE")

case "$CHOICE" in
    "ENGLISH")
        hyprctl switchxkblayout "$DEVICE" 0
        notify-send "Keyboard" "Layout: English (US)"
        ;;
    "SPANISH")
        hyprctl switchxkblayout "$DEVICE" 1
        notify-send "Keyboard" "Layout: Spanish"
        ;;
esac
