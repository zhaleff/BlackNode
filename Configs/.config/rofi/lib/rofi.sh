#!/usr/bin/env bash

t() {
    local name="$1"
    for _t_dir in features presets base; do
        if [[ -f "$ROFI_THEMES/$_t_dir/$name.rasi" ]]; then
            echo "$ROFI_THEMES/$_t_dir/$name.rasi"
            return 0
        fi
    done
    echo "$ROFI_THEMES/features/$name.rasi"
    return 1
}

rmenu() {
    local theme="$1"
    shift
    rofi -dmenu -theme "$theme" "$@"
}
