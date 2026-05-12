#!/usr/bin/env bash

hypr_config_dir="$HOME/.config/hypr"
animations_dir="$hypr_config_dir/animations"
main_conf="$hypr_config_dir/hyprland.conf"
cache_dir="$HOME/.cache/"
cache_file="$cache_dir/.hypr_conf_cache"

animation_files=$(find "$animations_dir" -maxdepth 1 -type f -name "*.conf" -exec basename {} \;)

if [ -z "$animation_files" ]; then
    echo "error: no .conf animation files found in $animations_dir"
    exit 1
fi

mkdir -p "$cache_dir"

cp "$main_conf" "$cache_file"


animation_files=$(find "$animations_dir" -maxdepth 1 -type f -name "*.conf" -exec basename {} \;)
selected_animation=$(echo "$animation_files" | rofi -dmenu -p "Select animation" -theme "$HOME/.config/rofi/animation/style.rasi")
[ -z "$selected_animation" ] && notify-send "No theme selected" && exit 1

selected_source="source = $animations_dir/$selected_animation"

sed -i "s|^source = .*$animations_dir/.*\.conf|$selected_source|" "$main_conf"
grep -qF "$selected_source" "$main_conf" || echo "$selected_source" >> "$main_conf"

echo "updated hypr.conf to: $selected_source"
notify-send "updated hypr.conf to: $selected_source"
