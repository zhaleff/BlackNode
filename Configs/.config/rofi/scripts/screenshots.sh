#!/bin/bash

shotsSave="$HOME/Pictures/Screenshots"
rofiConfig="$HOME/.config/rofi/styles/screenshots.rasi"

mkdir -p "$shotsSave"

for bin in grim slurp satty wl-copy hyprctl jq; do
  command -v "$bin" >/dev/null || { dunstify -a blacknode -u critical "Screenshot" "falta '$bin' en PATH"; exit 1; }
done

options="󰆞\n󰖯\n󰍹\n󱄄"

rofi_cmd() {
  rofi -dmenu \
    -mesg "Screenshot  " \
    -theme "$rofiConfig"
}

selected=$(echo -e "$options" | rofi_cmd) || exit 1
[[ -n "$selected" ]] || exit 1

geometry() {
  case "$1" in
    region)
      slurp -d
      ;;
    window)
      hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
      ;;
    output)
      slurp -o -r
      ;;
    all)
      echo ""
      ;;
  esac
}

case "$selected" in
  "󰆞") mode="region" ;;
  "󰖯") mode="window" ;;
  "󰍹") mode="output" ;;
  "󱄄") mode="all" ;;
  *) exit 1 ;;
esac

outfile="$shotsSave/satty-$(date '+%Y%m%d-%H%M%S').png"

if [[ "$mode" == "all" ]]; then
  grim -t ppm - | satty \
    --filename - \
    --output-filename "$outfile" \
    --copy-command wl-copy \
    --early-exit
else
  geo="$(geometry "$mode")"
  [[ -n "$geo" ]] || exit 1
  grim -g "$geo" -t ppm - | satty \
    --filename - \
    --output-filename "$outfile" \
    --copy-command wl-copy \
    --early-exit
fi
