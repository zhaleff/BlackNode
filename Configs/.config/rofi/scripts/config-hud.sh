#!/usr/bin/env bash

R="$HOME/.config/rofi"
THEME="$R/styles/config-hud.rasi"
CACHE="$HOME/.cache/blacknode/hud-state"
mkdir -p "$(dirname "$CACHE")"

read_state() {
    [ -f "$CACHE" ] && source "$CACHE"
}

write_state() {
    cat > "$CACHE" <<EOF
ANIM="${ANIM:-on}"
BLUR="${BLUR:-on}"
SHADOW="${SHADOW:-off}"
GAPS="${GAPS:-4}"
ROUND="${ROUND:-10}"
BORDER="${BORDER:-1}"
DIM="${DIM:-on}"
EOF
}

apply_hud() {
    hyprctl keyword animations:enabled "$( [ "$ANIM" = on ] && echo true || echo false )" 2>/dev/null
    hyprctl keyword decoration:blur:enabled "$( [ "$BLUR" = on ] && echo true || echo false )" 2>/dev/null
    hyprctl keyword decoration:shadow:enabled "$( [ "$SHADOW" = on ] && echo true || echo false )" 2>/dev/null
    hyprctl keyword general:gaps_in "$GAPS" 2>/dev/null
    hyprctl keyword general:gaps_out "$((GAPS + 4))" 2>/dev/null
    hyprctl keyword decoration:rounding "$ROUND" 2>/dev/null
    hyprctl keyword general:border_size "$BORDER" 2>/dev/null
    hyprctl keyword decoration:dim_special "$( [ "$DIM" = on ] && echo 0.3 || echo 0.0 )" 2>/dev/null
}

toggle() {
    [ "$1" = on ] && echo off || echo on
}

cycle() {
    local val="$1" list="$2"
    local i=0 found=false
    for v in $list; do
        [ "$v" = "$val" ] && found=true && break
        i=$((i + 1))
    done
    if ! $found; then
        echo "$list" | cut -d' ' -f1
        return
    fi
    local total
    total=$(echo "$list" | wc -w)
    i=$(( (i + 1) % total ))
    echo "$list" | cut -d' ' -f$((i + 1))
}

menu() {
    read_state
    local choice
    choice=$(printf "󰐥 Animations  %s\n󰡟 Blur        %s\n󰀻 Shadows    %s\n󰏘 Gaps       %spx\n Rounding   %spx\n󰟌 Border     %spx\n󰂷 Dim       %s\n󰅖 Reset" \
        "$ANIM" "$BLUR" "$SHADOW" "$GAPS" "$ROUND" "$BORDER" "$DIM" | \
        rofi -dmenu -p "Config" -theme-str "listview { lines: 8; }" -theme "$THEME")
    [ -z "$choice" ] && exit 0

    case "$choice" in
        "󰐥"*) ANIM=$(toggle "$ANIM") ;;
        "󰡟"*) BLUR=$(toggle "$BLUR") ;;
        "󰀻"*) SHADOW=$(toggle "$SHADOW") ;;
        "󰏘"*) GAPS=$(cycle "$GAPS" "0 2 4 6 8") ;;
        ""*) ROUND=$(cycle "$ROUND" "0 4 8 10 12 16 20") ;;
        "󰟌"*) BORDER=$(cycle "$BORDER" "1 2 3 4") ;;
        "󰂷"*) DIM=$(toggle "$DIM") ;;
        "󰅖"*) rm -f "$CACHE"; apply_hud; exit 0 ;;
        *) exit 0 ;;
    esac
    write_state
    apply_hud
    menu
}

menu
