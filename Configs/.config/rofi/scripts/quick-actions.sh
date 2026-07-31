#!/usr/bin/env bash

dir="$HOME/.config/rofi/styles"
state_dir="/tmp/blacknode"
gm_file="$state_dir/gamemode"
mkdir -p "$state_dir"

gm_on=0; [ -f "$gm_file" ] && gm_on=1
dnd_on=0; [ "$(dunstctl is-paused 2>/dev/null)" = "true" ] && dnd_on=1
nl_on=0; pgrep -f "python.*night-light.*--daemon" >/dev/null 2>&1 && nl_on=1
bt_on=0; [ "$(bluetoothctl show 2>/dev/null | grep Powered: | awk '{print $2}')" = "yes" ] && bt_on=1

[ "$gm_on"  -eq 1 ] && gm_icon="󰤄"  || gm_icon=""
[ "$dnd_on" -eq 1 ] && dnd_icon="󰂛" || dnd_icon="󰂚"
[ "$nl_on"  -eq 1 ] && nl_icon=""  || nl_icon=""
[ "$bt_on"  -eq 1 ] && bt_icon=""  || bt_icon=""

case "$(powerprofilesctl get 2>/dev/null || echo balanced)" in
    performance) perf_icon="" ;;
    power-saver) perf_icon="" ;;
    *)           perf_icon="" ;;
esac

active=""
[ "$gm_on" -eq 1 ] && active="${active}0,"
[ "$dnd_on" -eq 1 ] && active="${active}1,"
[ "$nl_on" -eq 1 ] && active="${active}2,"
[ "$bt_on" -eq 1 ] && active="${active}4,"

chosen=$(printf "%s\n" "$gm_icon" "$dnd_icon" "$nl_icon" "$perf_icon" "$bt_icon" | \
    rofi -dmenu -p "" -a "${active%,}" -theme "${dir}/quick-actions.rasi")

case "$chosen" in
    "$gm_icon")
        if [ "$gm_on" -eq 1 ]; then
            hyprctl keyword decoration:blur 1
            hyprctl keyword animations:enabled 1
            hyprctl keyword decoration:drop_shadow 1
            rm -f "$gm_file"
            notify-send -a "Quick Actions" "Game Mode" "Off"
        else
            hyprctl keyword decoration:blur 0
            hyprctl keyword animations:enabled 0
            hyprctl keyword decoration:drop_shadow 0
            touch "$gm_file"
            notify-send -a "Quick Actions" "Game Mode" "On"
        fi
        ;;
    "$dnd_icon")
        dunstctl set-paused toggle
        s=$(dunstctl is-paused)
        [ "$s" = "true" ] && notify-send -a "Quick Actions" "DND" "On" || notify-send -a "Quick Actions" "DND" "Off"
        ;;
    "$nl_icon")
        if [ "$nl_on" -eq 1 ]; then
            pkill -f "python.*night-light.*--daemon" 2>/dev/null
            brightnessctl set 100%
            notify-send -a "Quick Actions" "Night Light" "Off"
        else
            ~/.local/bin/blacknode/night-light --daemon &
            notify-send -a "Quick Actions" "Night Light" "On"
        fi
        ;;
    "$perf_icon")
        case "$(powerprofilesctl get 2>/dev/null || echo balanced)" in
            performance) powerprofilesctl set power-saver; notify-send -a "Quick Actions" "Profile" "Power Saver" ;;
            power-saver) powerprofilesctl set balanced;    notify-send -a "Quick Actions" "Profile" "Balanced" ;;
            *)           powerprofilesctl set performance; notify-send -a "Quick Actions" "Profile" "Performance" ;;
        esac
        ;;
    "$bt_icon")
        if [ "$bt_on" -eq 1 ]; then
            bluetoothctl power off
            notify-send -a "Quick Actions" "Bluetooth" "Off"
        else
            bluetoothctl power on
            notify-send -a "Quick Actions" "Bluetooth" "On"
        fi
        ;;
esac
