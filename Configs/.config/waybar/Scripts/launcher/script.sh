#!/usr/bin/env bash

layouts_dir="$HOME/.config/waybar/Layouts"
config_file="$HOME/.config/waybar/config.jsonc"

chosen=$(ls "$layouts_dir"/*.jsonc 2>/dev/null | xargs -I{} basename {} .jsonc | rofi -dmenu -i -p " Layout" -theme "$HOME/.config/rofi/launcher/themes/selector.rasi")

[[ -z "$chosen" ]] && exit 0

cat <<EOF > "$config_file"
// Copyright (c) 2026 Zhaleff && HollowSec. All Rights Reserved.
{
    "include": [
        "$layouts_dir/$chosen.jsonc"
    ]
}
EOF

killall waybar 2>/dev/null
waybar &
disown
