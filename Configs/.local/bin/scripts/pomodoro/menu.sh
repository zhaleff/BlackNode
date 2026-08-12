#!/usr/bin/env bash

STATE_FILE="/tmp/blacknode_pomodoro"
ICON="$(bn-icon timer)"

load_state() {
    if [[ -f "$STATE_FILE" ]]; then
        IFS='|' read -r mode remaining paused pid < "$STATE_FILE"
    else
        mode="idle"
        remaining=1500
        paused=false
        pid=""
    fi
}

save_state() {
    echo "$mode|$remaining|$paused|$pid" > "$STATE_FILE"
}

cleanup() {
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null
    rm -f "$STATE_FILE"
}

notify_timer() {
    local title="$1" msg="$2"
    dunstify -a "pomodoro" -i "$ICON" -t 8000 -r 2598 "$title" "$msg"
}

play_alarm() {
    if command -v paplay &>/dev/null; then
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
    fi
}

timer_tick() {
    local mode="$1" remaining="$2"
    while [[ "$remaining" -gt 0 ]]; do
        sleep 1
        remaining=$((remaining - 1))
        echo "$mode|$remaining|false|$$" > "$STATE_FILE"
    done
    play_alarm
    if [[ "$mode" == "work" ]]; then
        notify_timer "Pomodoro" "Work session done! Take a break."
        echo "break|$((5 * 60))|false|" > "$STATE_FILE"
    else
        notify_timer "Pomodoro" "Break over! Ready to focus."
        echo "idle|1500|false|" > "$STATE_FILE"
    fi
}

format_time() {
    local s=$1 m=$((s / 60)) sec=$((s % 60))
    printf "%02d:%02d" "$m" "$sec"
}

load_state

case "${1:-}" in
    "start")
        if [[ "$mode" == "idle" ]]; then
            remaining=${2:-1500}
            timer_tick "work" "$remaining" &
            pid=$!
            save_state
            notify_timer "Pomodoro" "Started! $(format_time $remaining)"
        fi
        exit ;;
    "pause")
        if [[ "$paused" == "false" && "$mode" != "idle" ]]; then
            [[ -n "$pid" ]] && kill "$pid" 2>/dev/null
            paused=true
            save_state
            notify_timer "Pomodoro" "Paused"
        elif [[ "$paused" == "true" ]]; then
            paused=false
            timer_tick "$mode" "$remaining" &
            pid=$!
            save_state
            notify_timer "Pomodoro" "Resumed"
        fi
        exit ;;
    "stop")
        cleanup
        notify_timer "Pomodoro" "Stopped"
        exit ;;
esac

CHOICE=$(printf '%s\n' \
    "  Pomodoro" \
    "  Work: 25min" \
    "  Work: 50min" \
    "  Break: 5min" \
    "  Break: 15min" \
    "󰏥  Start" \
    "󰏤  Pause / Resume" \
    "󰓛  Stop" \
    "󱑀  Status" \
    | rofi -dmenu -p "Pomodoro" -theme "$HOME/.config/rofi/submenu.rasi")

case "$CHOICE" in
    "  Pomodoro"|"󱑀  Status")
        load_state
        if [[ "$mode" == "idle" ]]; then
            notify-send "Pomodoro" "No active session"
        else
            local label="Work"
            [[ "$mode" == "break" ]] && label="Break"
            notify-send "Pomodoro" "${label}: $(format_time $remaining) left"
        fi ;;
    "  Work: 25min")
        cleanup
        remaining=$((25 * 60))
        timer_tick "work" "$remaining" &
        notify_timer "Pomodoro" "25min work started" ;;
    "  Work: 50min")
        cleanup
        remaining=$((50 * 60))
        timer_tick "work" "$remaining" &
        notify_timer "Pomodoro" "50min work started" ;;
    "  Break: 5min")
        cleanup
        remaining=$((5 * 60))
        timer_tick "break" "$remaining" &
        notify_timer "Pomodoro" "5min break started" ;;
    "  Break: 15min")
        cleanup
        remaining=$((15 * 60))
        timer_tick "break" "$remaining" &
        notify_timer "Pomodoro" "15min break started" ;;
    "󰏥  Start")
        load_state
        if [[ "$mode" == "idle" ]]; then
            remaining=1500
            timer_tick "work" "$remaining" &
            notify_timer "Pomodoro" "Started! 25min"
        else
            notify-send "Pomodoro" "Already running"
        fi ;;
    "󰏤  Pause / Resume")
        load_state
        if [[ "$paused" == "false" && "$mode" != "idle" ]]; then
            [[ -n "$pid" ]] && kill "$pid" 2>/dev/null
            paused=true; save_state
            notify_timer "Pomodoro" "Paused"
        elif [[ "$paused" == "true" ]]; then
            paused=false
            timer_tick "$mode" "$remaining" &
            save_state
            notify_timer "Pomodoro" "Resumed"
        else
            notify-send "Pomodoro" "No active session"
        fi ;;
    "󰓛  Stop")
        cleanup
        notify_timer "Pomodoro" "Stopped" ;;
esac
