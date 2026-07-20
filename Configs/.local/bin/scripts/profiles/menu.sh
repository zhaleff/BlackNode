#!/usr/bin/env bash

ROFI_SUB_THEME="$HOME/.config/rofi/submenu.rasi"
BASE="$HOME/.local/share/blacknode"
PROFILE_DIR="$BASE/profiles"
ACTIVE_FILE="$BASE/active_profile"
CONFIG_FILE="$HOME/.config/waybar/config.jsonc"
WAYBAR_PROFILES="$HOME/.config/waybar/Profiles"

get_active() {
    [[ -f "$ACTIVE_FILE" ]] && cat "$ACTIVE_FILE" || echo "default"
}

notify() { notify-send "$1" "$2"; }

apply_wallpaper() {
    local wall="$1"
    if ! pgrep -x "awww" > /dev/null; then
        awww &
        sleep 0.2
    fi
    awww img "$wall" --transition-type=random
    cp "$wall" ~/.config/hypr/hyprlock.png
    matugen image "$wall" -m dark --source-color-index 0
    killall -SIGUSR2 waybar && killall dunst && dunst &
    pkill -USR1 cava
    killall -SIGUSR1 kitty && pkill -USR1 firefox 2>/dev/null || killall -USR1 firefox 2>/dev/null
    notify "Wallpaper" "$(basename "$wall")"
}

random_wallpaper_from() {
    local dir="$1"
    [[ -d "$dir" ]] || return 1
    local wall
    wall=$(find "$dir" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | shuf -n 1)
    [[ -z "$wall" ]] && return 1
    echo "$wall"
}

random_blacknode_layout() {
    local layout
    layout=$(find "$HOME/.config/waybar/Layouts" -maxdepth 1 -name 'blacknode*.jsonc' -type f | shuf -n 1)
    echo "$layout"
}

set_include() {
    local layout="$1"
    [[ -f "$layout" ]] || return 1
    jq --arg path "$layout" '.include = [$path]' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    killall waybar 2>/dev/null
    waybar &
    disown
}

set_default() {
    echo "default" > "$ACTIVE_FILE"

    local wall
    wall=$(random_wallpaper_from "$HOME/Pictures/Wallpapers")
    [[ -n "$wall" ]] && apply_wallpaper "$wall"

    local layout
    layout=$(random_blacknode_layout)
    [[ -n "$layout" ]] && set_include "$layout"

    notify-send -t 2000 "Profile: default" "Original wallpapers + random BlackNode layout"
}

set_active() {
    local name="$1"
    echo "$name" > "$ACTIVE_FILE"

    local waybar_layout="$WAYBAR_PROFILES/$name.jsonc"
    if [[ -f "$waybar_layout" ]]; then
        set_include "$waybar_layout"
    fi

    local wall
    wall=$(random_wallpaper_from "$PROFILE_DIR/$name/walls")
    [[ -n "$wall" ]] && apply_wallpaper "$wall"

    notify-send -t 2000 "Profile: $name" "Waybar + wallpapers updated"
}

ACTIVE=$(get_active)

if [[ "$1" == "select" && -n "$2" ]]; then
    picked="$2"
    [[ "$picked" == "Default" ]] && picked="default"
    [[ "$picked" == "$ACTIVE" ]] && exit 0
    if [[ "$picked" == "default" ]]; then
        set_default
    else
        [[ -d "$PROFILE_DIR/$picked" ]] || exit 0
        set_active "$picked"
    fi
    exit 0
fi

choices="Default\n"
for d in "$PROFILE_DIR"/*/; do
    pname=$(basename "$d")
    [[ "$pname" == "default" ]] && continue
    mark=""
    [[ "$pname" == "$ACTIVE" ]] && mark="  "
    choices+="${pname}${mark}\n"
done

CHOICE=$(echo -e "$choices" | rofi -dmenu -p "Profile" -theme "$ROFI_SUB_THEME")

[[ -z "$CHOICE" ]] && exit 0

picked=$(echo "$CHOICE" | sed 's/  //')
[[ "$picked" == "Default" ]] && picked="default"
[[ "$picked" == "$ACTIVE" ]] && exit 0

if [[ "$picked" == "default" ]]; then
    set_default
else
    [[ -d "$PROFILE_DIR/$picked" ]] || exit 0
    set_active "$picked"
fi
