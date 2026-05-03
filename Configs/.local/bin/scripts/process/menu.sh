#!/usr/bin/env bash

notify() { notify-send "$1" "$2"; }

main() {
    local options=(
        "Top CPU"
        "Top Memory"
        "Kill Process"
        "Search"
    )

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Processes")

    case "$choice" in
        "Top CPU") proc_top_cpu ;;
        "Top Memory") proc_top_mem ;;
        "Kill Process") proc_kill ;;
        "Search") proc_search ;;
    esac
}

proc_top_cpu() {
    local procs=$(ps aux --sort=-%cpu | head -15 | awk '{print $2, $11, $3 "%"}')
    echo "$procs" | column -t | rofi -dmenu -i -p "Top CPU" -mesg "$procs" -lines 16
}

proc_top_mem() {
    local procs=$(ps aux --sort=-%mem | head -15 | awk '{print $2, $11, $4 "%"}')
    echo "$procs" | column -t | rofi -dmenu -i -p "Top Memory" -mesg "$procs" -lines 16
}

proc_kill() {
    local pids=$(ps aux | awk '{print $2, $11}' | rofi -dmenu -i -p "PID")
    local pid=$(echo "$pids" | awk '{print $1}')
    [[ -n "$pid" ]] && kill "$pid" && notify "Process" "Killed PID $pid"
}

proc_search() {
    local name
    name=$(rofi -dmenu -i -p "Search")
    [[ -n "$name" ]] && ps aux | grep "$name" | rofi -dmenu -i -p "Results"
}

main