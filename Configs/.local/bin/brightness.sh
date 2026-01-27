#!/bin/bash

dunstify -h int:value:"$(( ($(cat /sys/class/backlight/*/brightness) * 100) / $(cat /sys/class/backlight/*/max_brightness) ))"  -i ~/.config/dunst/assets/brightness.svg -t 500 -r 2593 "Brightness: $(( ($(cat /sys/class/backlight/*/brightness) * 100) / $(cat /sys/class/backlight/*/max_brightness) ))%"
