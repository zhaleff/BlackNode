#!/usr/bin/env bash

layouts_dir="$HOME/.config/waybar/Layouts"
config_file="$HOME/.config/waybar/config.jsonc"

# Profile-aware rofi: open the profile's dedicated command center if it exists.
ACTIVE_FILE="$HOME/.local/share/blacknode/active_profile"
if [[ -f "$ACTIVE_FILE" ]]; then
    active_profile="$(cat "$ACTIVE_FILE")"
    case "$active_profile" in
        study)
            exec "$HOME/.config/rofi/scripts/study.sh"
            ;;
        coding)
            exec "$HOME/.config/rofi/scripts/coding.sh"
            ;;
    esac
fi

entries=""
for f in "$layouts_dir"/*.jsonc; do
  name=$(basename "$f" .jsonc)
  entries+="$name\n"
done

chosen=$(echo -e "$entries" | rofi -dmenu -i -p " Layout" -theme "$HOME/.config/rofi/styles/submenu.rasi")

[[ -z "$chosen" ]] && exit 0

name="$chosen"

cat > "$config_file" <<EOF
{
  "include": [
    "~/.config/waybar/Layouts/${name}.jsonc"
  ],
  "layer": "top",
  "position": "top",
  "height": 30,
  "margin-left": 8,
  "margin-right": 8,
  "margin-top": 5,
  "margin-bottom": 0,
  "spacing": 2,
  "reload_style_on_change": true
}
EOF

killall waybar 2>/dev/null
waybar &
disown
