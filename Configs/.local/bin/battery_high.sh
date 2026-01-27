#!/usr/bin/env bash
while true; do [ $(cat /sys/class/power_supply/*/capacity) -gt 100 ] && [ $(cat /sys/class/power_supply/*/status) != "Complete" ] && dunstify -i ~/.config/dunst/assets/battery-full.svg -t 50000 -r 2594 "Battery Full: $(cat /sys/class/power_supply/*/capacity)%"; sleep 800; done
