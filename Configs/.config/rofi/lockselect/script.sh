#!/usr/bin/env bash

HYPRLOCK_PATH="$HOME/.config/hypr/hyprlock/"
ROFI_PATH="$HOME/.config/rofi/lockselect/style.rasi"

rofi_cmd() {
  rofi -dmenu \
    -mesg "Hyprlock select" \
    -theme $ROFI_PATH
}
