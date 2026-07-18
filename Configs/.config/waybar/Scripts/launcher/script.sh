#!/usr/bin/env bash

layouts_dir="$HOME/.config/waybar/Layouts"
config_file="$HOME/.config/waybar/config.jsonc"

declare -A DESCS
DESCS[blacknode]="Default — workspaces, media, system, clock"
DESCS[minimal]="Clean — workspaces, window, clock, idle"
DESCS[full]="Everything — workspaces, media, updates, weather, cpu, system, tray, clock"
DESCS[compact]="Tiny — workspaces, clock, menu"
DESCS[balanced]="Media left, system right, clean center"
DESCS[modern]="Minimal left, full hardware and tray right"
DESCS[classic]="Hardware left, clock and weather right"
DESCS[wide]="All modules, full layout, system focus"
DESCS[twin]="Media and window left, hardware right"
DESCS[split]="Heavy left side, window and weather right"
DESCS[edge]="Minimal edges, workspaces and window left, cpu and weather right"
DESCS[blend]="Media and info left, window and idle right"

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

chosen=$(echo -e "$entries" | rofi -dmenu -i -p " Layout" -theme "$HOME/.config/rofi/styles/submenu.rasi")

[[ -z "$chosen" ]] && exit 0

name="${chosen%% ─ *}"

jq --arg path "~/.config/waybar/Layouts/$name.jsonc" '.include = [$path]' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"

killall waybar 2>/dev/null
waybar &
disown
