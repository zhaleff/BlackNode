#!/usr/bin/env bash

themes_dir="$HOME/.config/rofi/launcher/themes"
config="$HOME/.config/rofi/config.rasi"

chosen=$(ls "$themes_dir"/*.rasi | xargs -I{} basename {} .rasi | rofi -dmenu -i -p " Tema" -theme "$themes_dir/selector.rasi")

[[ -z "$chosen" ]] && exit 0

echo "@theme \"$themes_dir/$chosen.rasi\"" > "$config"
