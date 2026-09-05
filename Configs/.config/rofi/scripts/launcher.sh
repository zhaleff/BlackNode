#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

choice=$(printf '%s\n' \
    "󰤨  WiFi" \
    "󰂯  Bluetooth" \
    "󰕾  Audio" \
    "󰎈  Music" \
    "󰌾  Clipboard" \
    "󰆞  Screenshots" \
    "  Record Screen" \
    "󰸉  Wallpaper" \
    "󰐥  Session" \
    | rofi -dmenu -theme "$THEME" -p "BlackNode")

[[ -z "$choice" ]] && exit 0

case "$choice" in
    *"WiFi")        exec bash "$ROFI_DIR/scripts/wifi.sh" ;;
    *"Bluetooth")   exec bash "$ROFI_DIR/scripts/bluetooth.sh" ;;
    *"Audio")       exec bash "$ROFI_DIR/scripts/audio.sh" ;;
    *"Music")       exec bash "$ROFI_DIR/scripts/musicPlayer.sh" ;;
    *"Clipboard")   exec bash "$ROFI_DIR/scripts/clipboard.sh" ;;
    *"Record Screen") exec bash "$ROFI_DIR/scripts/recordscreen.sh" ;;
    *"Screenshots") exec bash "$ROFI_DIR/scripts/screenshots.sh" ;;
    *"Wallpaper")   exec bash "$ROFI_DIR/scripts/wallselect.sh" ;;
    *"Session")     exec bash "$ROFI_DIR/scripts/powermenu.sh" ;;
esac
