#!/bin/bash

WALL_DIR="$HOME/.local/share/wallpapers"
CONFIG_PATH="$HOME/.config/hypr/hyprpaper.conf"

SELECTED=$(find "$WALL_DIR" \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
    | while read -r img; do
        printf '%s\0icon\x1f%s\n' "$img" "$img"
      done \
    | rofi -dmenu -show-icons -theme "$HOME/.config/rofi/wallselect/style.rasi"
)

# Si no se eligió nada, salir
[ -z "$SELECTED" ] && exit 0

# Detener hyprpaper si ya está corriendo
if pgrep -x hyprpaper >/dev/null; then
    pkill hyprpaper
fi

# Crear nueva config compatible con hyprpaper 0.8.0
cat > "$CONFIG_PATH" << EOF
ipc = on
splash = false

wallpaper {
    monitor = eDP-1
    path = $SELECTED
    # fit_mode = cover
}
EOF

# Lanzar hyprpaper
hyprpaper &

