#!/bin/bash

player=$(playerctl -l 2>/dev/null | head -n 1)

# Rofi theme path
rofi_theme="$HOME/.config/rofi/musicPlayer/style.rasi"


title=$(playerctl -p "$player" metadata title)
artist=$(playerctl -p "$player" metadata artist)
album=$(playerctl -p "$player" metadata album)
artUrl=$(playerctl -p "$player" metadata mpris:artUrl | sed 's/^file:\/\///')

loop=$(playerctl $player loop)
status=$(playerctl -p "$player" status 2>/dev/null)
info="🎵 $title — $artist [$album]"

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
