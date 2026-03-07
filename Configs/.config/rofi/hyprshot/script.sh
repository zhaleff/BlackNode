#!/bin/bash

# The script serves to selected different types of captures in Hyprshot
# Path: ~/.local/share/screenshots/
# Probably the repository doesn't exist... So we're going to create it just in case
# You create the folder with the command
# mkdir -p ~/.local/share/screenshots and
# cd ~/.local/share/screenshots this is save to screenshots
# If you pictures folder is named differently than "Pictures", just replace "Pictures" with the actual
# name of you folder. For example, if it's called "Imagenes", it would be:

hyprshotSave="$HOME/.local/share/screenshots/"
rofiConfig="$HOME/.config/rofi/hyprshot/style.rasi"

options=" \n \n \n \n "

rofi_cmd() {
  rofi -dmenu \
    -mesg "Screenshot  " \
    -theme $rofiConfig
}

selected=$(echo -e "$options" | rofi_cmd || {
   exit 1
})

declare -A actions=(
  [" "]="hyprshot -m region -o $hyprshotSave"
  [" "]="hyprshot -m window -o $hyprshotSave"
  [" "]="hyprshot -m output -o $hyprshotSave"
  [" "]="hyprshot -m output -o $hyprshotSave"
  [" "]="exit 0"
)

run() {
  local cmd="${actions[$1]}"
  [[ -n "$cmd" ]] && $cmd || exit 0
  [[ $? -ne 0 ]] && log_error "Failed to execute: $cmd"
}

run "$selected"
