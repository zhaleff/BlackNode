#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

choice=$(printf '%s\n' \
    "󰤨  WiFi" \
    "󰂯  Bluetooth" \
    "󰕾  Audio" \
    "  Bookmarks" \
    "  Keyboard Layout" \
    "󰎈  Music" \
    "  Clipboard" \
    "󰌌  Shorcuts" \
    "  Pomodoro" \
    "󰆞  Screenshots" \
    "  Record Screen" \
    "󰸉  Wallpaper" \
    "  Kill Process" \
    "󰞅  Emoji Picker" \
    "󰑓  Reload" \
    "󰎕  Whats New" \
    "󰐥  Session" \
    | rofi -dmenu -theme "$THEME" -p "BlackNode")

[[ -z "$choice" ]] && exit 0

case "$choice" in
    *"WiFi")        exec bash "$ROFI_DIR/scripts/wifi.sh" ;;
    *"Bluetooth")   exec bash "$ROFI_DIR/scripts/bluetooth.sh" ;;
    *"Audio")       exec bash "$ROFI_DIR/scripts/audio.sh" ;;
    *"Bookmarks")   exec bash "$ROFI_DIR/scripts/bookmarks.sh" ;;
    *"Keyboard Layout") exec bash "$ROFI_DIR/scripts/kb-layout.sh" ;;
    *"Music")       exec bash "$ROFI_DIR/scripts/musicPlayer.sh" ;;
    *"Clipboard")   exec bash "$ROFI_DIR/scripts/clipboard.sh" ;;
    *"Shorcuts")    exec bash "$ROFI_DIR/scripts/shortcuts.sh" ;;
    *"Pomodoro")    exec bash "$ROFI_DIR/scripts/pomodoro.sh" ;;
    *"Record Screen") exec bash "$ROFI_DIR/scripts/recordscreen.sh" ;;
    *"Screenshots") exec bash "$ROFI_DIR/scripts/screenshots.sh" ;;
    *"Wallpaper")   exec bash "$ROFI_DIR/scripts/wallselect.sh" ;;
    *"Kill Process") exec bash "$ROFI_DIR/scripts/killprocess.sh" ;;
    *"Emoji Picker") exec bash "$ROFI_DIR/scripts/emoji.sh" ;;
    *"Reload")      exec bash "$ROFI_DIR/scripts/reload.sh" ;;
    *"Whats New")   exec bash "$ROFI_DIR/scripts/whatnews.sh" ;;
    *"Session")     exec bash "$ROFI_DIR/scripts/powermenu.sh" ;;
esac
