#!/usr/bin/env bash
ref_new_moon=$(date -d "2000-01-06 18:14:00 UTC" +%s)
lunar_cycle=2551443
now=$(date +%s)
elapsed=$(( now - ref_new_moon ))
phase=$(( elapsed % lunar_cycle ))
phase_index=$(( phase * 8 / lunar_cycle ))
case $phase_index in
    0) icon="🌑"; name="New Moon";;
    1) icon="🌒"; name="Waxing Crescent";;
    2) icon="🌓"; name="First Quarter";;
    3) icon="🌔"; name="Waxing Gibbous";;
    4) icon="🌕"; name="Full Moon";;
    5) icon="🌖"; name="Waning Gibbous";;
    6) icon="🌗"; name="Last Quarter";;
    7) icon="🌘"; name="Waning Crescent";;
esac
printf '{"text":"%s","tooltip":"%s"}' "$icon" "$name"
