#!/usr/bin/env bash

layouts_dir="$HOME/.config/waybar/Layouts"
config_file="$HOME/.config/waybar/config.jsonc"

declare -A DESCS
DESCS[blacknode]="Default — workspaces, media, system, clock"
DESCS[minimal]="Clean — workspaces, window, network, clock"
DESCS[full]="Everything — workspaces, media, system, tray, clock"
DESCS[dev]="Dev mode — workspaces, window, cpu/mem, network, clock"
DESCS[compact]="Tiny — workspaces, clock, menu"

entries=""
for f in "$layouts_dir"/*.jsonc; do
  name=$(basename "$f" .jsonc)
  desc="${DESCS[$name]:-}"
  if [[ -n "$desc" ]]; then
    entries+="$name  ─  $desc\n"
  else
    entries+="$name\n"
  fi
done

chosen=$(echo -e "$entries" | rofi -dmenu -i -p " Layout" -theme "$HOME/.config/rofi/launcher/themes/selector.rasi")

[[ -z "$chosen" ]] && exit 0

name="${chosen%% ─ *}"

cat <<EOF > "$config_file"
// Copyright (c) 2026 Zhaleff && HollowSec. All Rights Reserved.
{
    "include": [
        "$layouts_dir/$name.jsonc"
    ]
}
EOF

killall waybar 2>/dev/null
waybar &
disown
