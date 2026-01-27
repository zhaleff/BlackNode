#!/bin/bash

dunstify -h int:value:"$(pamixer --get-volume)" -i ~/.config/dunst/assets/volume.svg -t 2000 -r 2593 "Volume: $(pamixer --get-volume) %"
