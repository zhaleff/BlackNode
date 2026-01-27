#!/bin/bash
while true; do [ $(cat /sys/class/power_supply/*/capacity) -le 20 ] && [ $(cat /sys/class/power_supply/*/status) != "Charging" ] && dunstify -u critical -i ~/.config/dunst/assets/battery-low.svg -t 5000 -r 2594 "Battery Low: $(cat /sys/class/power_supply/*/capacity)%"; sleep 600; done

