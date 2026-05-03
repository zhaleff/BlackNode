#!/usr/bin/env bash#

# ==========================================
# BLACKNODE SERVICES
# ==========================================

ROFI_THEME="$HOME/.config/rofi/menu.rasi"

main() {
    local running
    running=$(systemctl list-units --type=service --state=running | awk '/\.service/ {print $1}' | wc -l)
    local failed
    failed=$(systemctl list-units --type=service --state=failed | awk '/\.service/ {print $1}')
    
    rofi -dmenu -i -p "Services" -theme "$ROFI_THEME" \
        -mesg "Running: $running | Failed: $(echo $failed | wc -w)" -lines 5
}

main