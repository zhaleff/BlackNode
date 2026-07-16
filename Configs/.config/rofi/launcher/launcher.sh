#!/usr/bin/env bash

styles_dir="$HOME/.config/rofi/styles"

chosen=$(find "$styles_dir" -name '*.rasi' -exec basename {} .rasi \; | sort | rofi -dmenu -i -p " Rofi Theme" -theme "$HOME/.config/rofi/styles/submenu.rasi")

[[ -z "$chosen" ]] && exit 0

echo "@theme \"$styles_dir/$chosen.rasi\"" > "$HOME/.config/rofi/config.rasi"
