#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"

choice=$(printf '%s\n' \
    "󰤨  WiFi" \
    "󰂯  Bluetooth" \
    "󰕾  Audio" \
    "󰂚  Notification" \
    "󰑓  Reload" \
    "  Bookmarks" \
    "  Keyboard Layout" \
    "󰎈  Music" \
    "  Clipboard" \
    "󰌌  Shorcuts" \
    "󰍹  Monitor" \
    "  Pomodoro" \
    "󰆞  Screenshots" \
    "  Record Screen" \
    "󰸉  Wallpaper" \
    "󰞅  Emoji Picker" \
    "󰎕  Whats New" \
    "󰐥  Session" \
    | rofi -dmenu -theme "$THEME" -p "BlackNode")

[[ -z "$choice" ]] && exit 0

case "$choice" in
    *"WiFi")        exec bash "$ROFI_DIR/scripts/network/wifi.sh" ;;
    *"Bluetooth")   exec bash "$ROFI_DIR/scripts/bluetooth/bluetooth.sh" ;;
    *"Audio")       exec bash "$ROFI_DIR/scripts/audio/audio.sh" ;;
    *"Notification")       exec bash "$ROFI_DIR/scripts/system/notification.sh" ;;
    *"Reload")      exec bash "$ROFI_DIR/scripts/system/reload.sh" ;;
    *"Bookmarks")   exec bash "$ROFI_DIR/scripts/utilities/bookmarks.sh" ;;
    *"Keyboard Layout") exec bash "$ROFI_DIR/scripts/keyboard/kb-layout.sh" ;;
    *"Music")       exec bash "$ROFI_DIR/scripts/audio/musicPlayer.sh" ;;
    *"Clipboard")   exec bash "$ROFI_DIR/scripts/utilities/clipboard.sh" ;;
    *"Shorcuts")    exec bash "$ROFI_DIR/scripts/keyboard/shortcuts.sh" ;;
    *"Monitor")     exec bash "$ROFI_DIR/scripts/display/monitor.sh" ;;
    *"Pomodoro")    exec bash "$ROFI_DIR/scripts/pomodoro/pomodoro.sh" ;;
    *"Record Screen") exec bash "$ROFI_DIR/scripts/recording/recordscreen.sh" ;;
    *"Screenshots") exec bash "$ROFI_DIR/scripts/recording/screenshots.sh" ;;
    *"Wallpaper")   exec bash "$ROFI_DIR/scripts/appearance/wallpaper.sh" ;;
    *"Emoji Picker") exec bash "$ROFI_DIR/scripts/utilities/emoji.sh" ;;
    *"Whats New")   exec bash "$ROFI_DIR/scripts/system/whatnews.sh" ;;
    *"Session")     exec bash "$ROFI_DIR/scripts/system/powermenu.sh" ;;
esac
