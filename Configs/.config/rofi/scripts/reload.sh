#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
ICON="/tmp/blacknode-icons/reload.svg"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

reload_waybar() {
    pkill -x waybar
    sleep 0.3
    waybar >/tmp/waybar.log 2>&1 &
    disown
}

reload_spotify() {
  pkill -x spotify 
  sleep 0.5 
  spotify 2>&1 &
  disown
}

reload_hyprland() {
    hyprctl reload
}

reload_dunst() {
    pkill -x dunst
    sleep 0.3
    dunst &
    disown
}

reload_menu() {
    local choice
    choice=$(printf '%s\n' \
        "󰌍  Back" \
        "  bar (Waybar)" \
        "  window manager (Hyprland)" \
        "󰂚  notifications (Dunst)" \
        "  Spotify"  \
        "󰑓  everything" \
        | rofi -dmenu -theme "$THEME" -p "Reload")

    case "$choice" in
        *"Back")
            exec bash "$ROFI_DIR/scripts/launcher.sh" ;;
        *"bar"*)
            reload_waybar
            notify-send "Reload" "Bar reloaded" -i $ICON;;
        *"Spotify"*)
            reload_spotify  
            notify-send "Reload" "Spotify reloaded" -i $ICON ;;
        *"window manager"*)
            reload_hyprland
            notify-send "Reload" "Window manager reloaded" -i $ICON ;;
        *"notifications"*)
            reload_dunst
            notify-send "Reload" "Notifications reloaded" -i $ICON ;;
        *"everything")
            reload_hyprland
            reload_waybar
            reload_spotify
            reload_dunst
            notify-send "Reload" "Everything reloaded" -i $ICON ;;
    esac
}

reload_menu
