#!/usr/bin/env bash
ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/presets/submenu.rasi"
SHOTS_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SHOTS_DIR"

for bin in grim slurp satty wl-copy hyprctl jq; do
    command -v "$bin" >/dev/null 2>&1 || { notify-send "Screenshot" "Missing: $bin"; exit 1; }
done

choice=$(printf '%s\n' \
    "󰆞  Region" \
    "󰖯  Window" \
    "󰍹  Output" \
    "󱄄  All" \
    | rofi -dmenu -theme "$THEME" -p "Screenshot")

[ -z "$choice" ] && exit 0

outfile="$SHOTS_DIR/satty-$(date '+%Y%m%d-%H%M%S').png"

case "$choice" in
    *"Region")
        geo=$(slurp -d) || exit 1
        grim -g "$geo" -t ppm - | satty --filename - --output-filename "$outfile" --copy-command wl-copy --early-exit
        ;;
    *"Window")
        geo=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$geo" -t ppm - | satty --filename - --output-filename "$outfile" --copy-command wl-copy --early-exit
        ;;
    *"Output")
        geo=$(slurp -o -r) || exit 1
        grim -g "$geo" -t ppm - | satty --filename - --output-filename "$outfile" --copy-command wl-copy --early-exit
        ;;
    *"All")
        grim -t ppm - | satty --filename - --output-filename "$outfile" --copy-command wl-copy --early-exit
        ;;
esac
