#!/usr/bin/env bash

layouts_dir="$HOME/.config/waybar/Layouts"
active_file="$layouts_dir/active.jsonc"

declare -A DESCS
DESCS[blacknode]="Default — workspaces, media, system, clock"
DESCS[minimal]="Clean — workspaces, window, clock, idle"
DESCS[full]="Everything — workspaces, media, updates, weather, cpu, system, tray, clock"
DESCS[dev]="Dev mode — workspaces, window, target, htb-vpn, cpu/mem, clock"
DESCS[compact]="Tiny — workspaces, clock, menu"

entries=""
for f in "$layouts_dir"/*.jsonc; do
  name=$(basename "$f" .jsonc)
  [[ "$name" == "active" ]] && continue
  desc="${DESCS[$name]:-}"
  if [[ -n "$desc" ]]; then
    entries+="$name  ─  $desc\n"
  else
    entries+="$name\n"
  fi
done

chosen=$(echo -e "$entries" | rofi -dmenu -i -p " Layout" -theme "$HOME/.config/rofi/styles/submenu.rasi")

[[ -z "$chosen" ]] && exit 0

name="${chosen%% ─ *}"

cat <<EOF > "$active_file"
{
  "include": [
    "~/.config/waybar/Layouts/$name.jsonc"
  ]
}
EOF

killall waybar 2>/dev/null
waybar &
disown