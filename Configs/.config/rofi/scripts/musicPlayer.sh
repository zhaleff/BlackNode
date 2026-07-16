#!/bin/bash

player=$(playerctl -l 2>/dev/null | head -n 1)
[[ -z "$player" ]] && notify-send "Music" "No player running" && exit 1

rofi_theme="$HOME/.config/rofi/styles/musicPlayer.rasi"

title=$(playerctl -p "$player" metadata title 2>/dev/null)
artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
album=$(playerctl -p "$player" metadata album 2>/dev/null)
artUrl=$(playerctl -p "$player" metadata mpris:artUrl 2>/dev/null | sed 's/^file:\/\///')

status=$(playerctl -p "$player" status 2>/dev/null)
play=$([[ "$status" == "Playing" ]] && echo "⏸ " || echo "▶ ")

options="󰒮 \n$play\n󰒭 "

choice=$(echo -e "$options" | rofi -dmenu -theme "$rofi_theme" -mesg "󰎆 $title" --icon="$artUrl")

case "$choice" in
    "󰒭 ")
        playerctl -p "$player" next
    ;;
    "$play")
        if [[ "$status" == "Playing" ]]; then
            playerctl -p "$player" pause
        else
            playerctl -p "$player" play
        fi
    ;;
    "󰒮 ")
        playerctl -p "$player" previous
        sleep 2
    ;;
esac
