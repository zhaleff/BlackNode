#!/usr/bin/env bash

R="$HOME/.config/rofi"
OVERRIDES="$HOME/.config/hypr/settings/overrides.lua"
LIST_THEME="$R/styles/config-list.rasi"
CACHE="$HOME/.cache/blacknode/hud-state"
mkdir -p "$(dirname "$CACHE")"

read_state() {
    [ -f "$CACHE" ] && source "$CACHE"
}
read_state
: "${ANIM:=true}" "${BLUR:=true}" "${SHADOW:=false}" "${DIM:=0.3}" "${GAPS_IN:=3}" "${GAPS_OUT:=7}" "${BORDER:=1}" "${ROUND:=10}"

write_state() {
    cat > "$CACHE" <<EOF
ANIM=$ANIM
BLUR=$BLUR
SHADOW=$SHADOW
DIM=$DIM
GAPS_IN=$GAPS_IN
GAPS_OUT=$GAPS_OUT
BORDER=$BORDER
ROUND=$ROUND
EOF
}

write_lua() {
    cat > "$OVERRIDES" <<EOF
hl.config({
    decoration = {
        rounding = $ROUND,
        dim_special = $DIM,
        blur = { enabled = $BLUR },
        shadow = { enabled = $SHADOW },
    },
    general = {
        gaps_in = $GAPS_IN,
        gaps_out = $GAPS_OUT,
        border_size = $BORDER,
    },
    animations = {
        enabled = $ANIM,
    },
})
EOF
    hyprctl reload
}

apply() {
    write_lua
    write_state
}

animation_menu() {
    local choice
    choice=$(printf "󰐥 Animations  %s" "$ANIM" | rofi -dmenu -p "Animations" -theme-str "listview { lines: 1; }" -theme "$LIST_THEME")
    [ -z "$choice" ] && return
    [[ "$choice" == "󰐥"*true ]] && ANIM=false || ANIM=true
    apply
    animation_menu
}

visuals_menu() {
    local DIM_LABEL
    [[ "$DIM" == "0.0" ]] && DIM_LABEL=off || DIM_LABEL=on
    local choice
    choice=$(printf "󰡟 Blur  %s\n󰀻 Shadow  %s\n󰂷 Dim  %s" "$BLUR" "$SHADOW" "$DIM_LABEL" | rofi -dmenu -p "Visuals" -theme-str "listview { lines: 3; }" -theme "$LIST_THEME")
    [ -z "$choice" ] && return
    case "$choice" in
        "󰡟"*true) BLUR=false;; "󰡟"*) BLUR=true;;
        "󰀻"*true) SHADOW=false;; "󰀻"*) SHADOW=true;;
        "󰂷"*on) DIM="0.0";; "󰂷"*) DIM="0.3";;
    esac
    apply
    visuals_menu
}

layout_menu() {
    local choice
    choice=$(printf "󰏘 Gaps In   %spx\n󰏘 Gaps Out  %spx\n󰟌 Border    %spx" "$GAPS_IN" "$GAPS_OUT" "$BORDER" | rofi -dmenu -p "Layout" -theme-str "listview { lines: 3; }" -theme "$LIST_THEME")
    [ -z "$choice" ] && return
    if [[ "$choice" == *"Gaps In"* ]]; then
        local v
        v=$(echo "0\n2\n4\n6\n8" | rofi -dmenu -p "Gaps In" -theme-str "listview { lines: 5; }" -theme "$LIST_THEME")
        [ -n "$v" ] && GAPS_IN="$v"
    elif [[ "$choice" == *"Gaps Out"* ]]; then
        local v
        v=$(echo "0\n4\n8\n12\n16" | rofi -dmenu -p "Gaps Out" -theme-str "listview { lines: 5; }" -theme "$LIST_THEME")
        [ -n "$v" ] && GAPS_OUT="$v"
    elif [[ "$choice" == *"Border"* ]]; then
        local v
        v=$(echo "1\n2\n3\n4" | rofi -dmenu -p "Border" -theme-str "listview { lines: 4; }" -theme "$LIST_THEME")
        [ -n "$v" ] && BORDER="$v"
    fi
    apply
    layout_menu
}

rounding_menu() {
    local choice
    choice=$(printf " Rounding  %spx" "$ROUND" | rofi -dmenu -p "Rounding" -theme-str "listview { lines: 1; }" -theme "$LIST_THEME")
    [ -z "$choice" ] && return
    if [[ "$choice" == ""* ]]; then
        local v
        v=$(echo "0\n4\n8\n10\n12\n16\n20" | rofi -dmenu -p "px" -theme-str "listview { lines: 7; }" -theme "$LIST_THEME")
        [ -n "$v" ] && ROUND="$v"
        apply
        rounding_menu
    fi
}

CHOICE=$(printf "󰐥\n󰡟\n󰏘\n" | rofi -dmenu -p "Config" -theme-str "listview { lines: 4; }" -theme "$R/shared/menu.rasi")
case "$CHOICE" in
    "󰐥") animation_menu ;;
    "󰡟") visuals_menu ;;
    "󰏘") layout_menu ;;
    "") rounding_menu ;;
esac
