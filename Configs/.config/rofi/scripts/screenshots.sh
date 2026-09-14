#!/usr/bin/env bash

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
SHOTS_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SHOTS_DIR"

for bin in grim slurp satty wl-copy hyprctl jq notify-send; do
  command -v "$bin" >/dev/null 2>&1 || { notify-send "Screenshot" "Missing: $bin"; exit 1; }
done

mode_choice=$(printf '%s\n' \
  "󰌍  Back" \
  "󰆞  Region" \
  "󰖯  Window" \
  "󰍹  Output" \
  "󱄄  All" \
  | rofi -dmenu -theme "$THEME" -p "Screenshot")

[ -z "$mode_choice" ] && exit 0
[[ "$mode_choice" == *"Back" ]] && exec bash "$ROFI_DIR/scripts/launcher.sh"

outfile="$SHOTS_DIR/shot-$(date '+%Y%m%d-%H%M%S').png"

case "$mode_choice" in
  *"Region")
    geo=$(slurp -d) || exit 1
    grim -g "$geo" "$outfile"
    ;;
  *"Window")
    geo=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    grim -g "$geo" "$outfile"
    ;;
  *"Output")
    geo=$(slurp -o -r) || exit 1
    grim -g "$geo" "$outfile"
    ;;
  *"All")
    grim "$outfile"
    ;;
esac

[ -f "$outfile" ] || exit 1

action_choice=$(printf '%s\n' \
  "󰄲  Copy" \
  "󰏫  Edit (satty)" \
  "󰆓  Save only" \
  "󰆴  Delete" \
  | rofi -dmenu -theme "$THEME" -p "Screenshot saved")

case "$action_choice" in
  *"Copy")
    wl-copy < "$outfile"
    notify-send "Screenshot" "Copied to clipboard"
    ;;
  *"Edit"*)
    satty --filename "$outfile" --output-filename "$outfile" --copy-command wl-copy --early-exit
    ;;
  *"Delete")
    rm -f "$outfile"
    notify-send "Screenshot" "Deleted"
    ;;
  *"Save only"|*)
    notify-send "Screenshot" "Saved to $outfile"
    ;;
esac
