#!/usr/bin/env bash

# ============================================
# BLACKNODE SYSTEM - with notifications
# ============================================

notify() { notify-send "$1" "$2"; }
ROFI_THEME="$HOME/.config/rofi/menu.rasi"

main() {
    local options=(
        "Info"
        "CPU"
        "Memory"
        "Battery"
        "Temperature"
        "Disk"
        "Top CPU"
        "Top Memory"
        "Kill Process"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "System" -theme "$ROFI_THEME")

    case "$choice" in
        "Info") sys_info ;;
        "CPU") sys_cpu ;;
        "Memory") sys_memory ;;
        "Battery") sys_battery ;;
        "Temperature") sys_temp ;;
        "Disk") sys_disk ;;
        "Top CPU") top_cpu ;;
        "Top Memory") top_mem ;;
        "Kill Process") kill_proc ;;
    esac
}

# --------------------------------------------
sys_info() {
    local os=$(uname -o)
    local kernel=$(uname -r)
    local uptime=$(uptime -p)
    local mem=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    local cpu=$(lscpu | awk '/Model name/ {sub(/:.*/, "", $0); print $0}' | head -1)
    local pkgs=$(pacman -Qq | wc -l)
    
    notify "System" "Uptime: $uptime | Mem: $mem | CPU: $cpu | Pkgs: $pkgs"
}

# --------------------------------------------
sys_cpu() {
    local usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    local freq=$(lscpu | awk '/CPU MHz/ {print $3 " MHz"}')
    notify "CPU" "Usage: ${usage}% | Freq: $freq"
}

# --------------------------------------------
sys_memory() {
    local mem=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    local swap=$(free -h | awk '/Swap:/ {print $3 "/" $2}')
    notify "Memory" "Used: $mem | Swap: $swap"
}

# --------------------------------------------
sys_battery() {
    local bat=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
    local status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)
    notify "Battery" "${bat}% - $status"
}

# --------------------------------------------
sys_temp() {
    local temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1 | awk '{print $1/1000 "°C"}')
    notify "Temperature" "CPU: $temp"
}

# --------------------------------------------
sys_disk() {
    local root=$(df -h / | awk 'NR==2 {print $3 "/" $2}')
    notify "Disk" "Root: $root"
}

# --------------------------------------------
top_cpu() {
    local procs=$(ps aux --sort=-%cpu | head -6 | awk '{print $11 " " $3 "%"}')
    notify "Top CPU" "$procs"
}

# --------------------------------------------
top_mem() {
    local procs=$(ps aux --sort=-%mem | head -6 | awk '{print $11 " " $4 "%"}')
    notify "Top Memory" "$procs"
}

# --------------------------------------------
kill_proc() {
    local pids=$(ps aux --sort=-%cpu | head -15 | awk '{print $2 " " $11}' | rofi -dmenu -i -p "Kill" -theme "$ROFI_THEME")
    local pid=$(echo "$pids" | awk '{print $1}')
    if [[ -n "$pid" ]]; then
        kill "$pid" 2>/dev/null && notify "Process" "Killed $pid" || notify "Process" "Failed to kill"
    fi
}

main