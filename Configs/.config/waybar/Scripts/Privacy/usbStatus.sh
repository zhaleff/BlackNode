#!/usr/bin/env bash
tip="" n=0
for i in /sys/bus/usb/devices/*:*; do
  [ "$(<"$i/bInterfaceClass")" = "08" ] || continue
  d=${i%:*}
  n=$((n+1))
  prod=$(<"$d/product") mfr=$(cat "$d/manufacturer" 2>/dev/null)
  tip+="󰋊  ${prod:-USB storage}"$'\n'
  tip+="   󰧱 ${mfr:-Unknown}"$'\n'
  tip+="    $(<"$d/idVendor"):$(<"$d/idProduct")"$'\n'
  tip+="   󰓅 $(<"$d/speed") Mbps"$'\n'
  blk=$(ls -d "$i"/host*/target*/*/block/* 2>/dev/null | head -1)
  if [ -n "$blk" ]; then
    name=$(basename "$blk")
    while read -r dev size fs label mnt; do
      tip+="   󰉋 /dev/$dev · $size · ${fs:-no fs} · ${label:--}"$'\n'
      tip+="   󰁔 ${mnt:-not mounted}"$'\n'
    done < <(lsblk -nr -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT "/dev/$name")
  fi
  tip+=$'\n'
done

jq -nc --arg t "󱇰  USB storage ($n)"$'\n\n'"${tip%$'\n'}" '{text:"󱇰",class:"storage",tooltip:$t}'
