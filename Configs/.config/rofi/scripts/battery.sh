#!/usr/bin/env bash

STYLE="$HOME/.config/rofi/styles/battery.rasi"
CURRENT=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)

OPTIONS=""
for item in "powersave:󰌪 " "schedutil:󰁹 " "performance:󰓅 "; do
    key="${item%%:*}"
    label="${item##*:}"
    if [[ "$CURRENT" == "$key" ]]; then
        OPTIONS+="$label\0urgent\x1ftrue\n"
    else
        OPTIONS+="$label\n"
    fi
done

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "󰂄" -theme "$STYLE") || exit 0
[[ -z "$CHOICE" ]] && exit 0

case "$CHOICE" in
    *"Powersave"*)   sudo cpupower frequency-set -g powersave ;;
    *"Schedutil"*)   sudo cpupower frequency-set -g schedutil ;;
    *"Performance"*) sudo cpupower frequency-set -g performance ;;
esac

dunstify -a "battery" -t 3000 "CPU: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
