#!/usr/bin/env bash#

ROFI_THEME="$HOME/.config/rofi/menu.rasi"

main() {
    local os=$(uname -o)
    local kernel=$(uname -r)
    local uptime=$(uptime -p)
    local mem=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    local cpu=$(lscpu | awk '/Model name/ {sub(/:.*/, "", $0); print $0}' | head -1)
    local pkgs=$(pacman -Qq | wc -l)
    
    rofi -dmenu -i -p "System Info" -theme "$ROFI_THEME" \
        -mesg "OS: $os
Kernel: $kernel
Uptime: $uptime
Memory: $mem
CPU: $cpu
Packages: $pkgs" -lines 6
}

main