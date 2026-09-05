#!/usr/bin/env bash

status() {
    if dunstctl is-paused | grep -q true; then
        printf '{"text":"󰂛","class":"dnd-active","tooltip":"Do Not Disturb: On"}\n'
    else
        printf '{"text":"󰂚","class":"dnd-inactive","tooltip":"Do Not Disturb: Off"}\n'
    fi
}

case "$1" in
    toggle) dunstctl set-paused toggle ;;
    *) status ;;
esac
