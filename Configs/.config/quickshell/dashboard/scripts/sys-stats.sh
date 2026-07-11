#!/usr/bin/env bash
CACHE="$HOME/.config/quickshell/dashboard/cache/sys-stats.json"

if [ -f "$CACHE" ] && [ "$(find "$CACHE" -mmin -1 2>/dev/null)" ]; then
  cat "$CACHE"
  exit 0
fi

hname=$(cat /proc/sys/kernel/hostname 2>/dev/null || echo "blacknode")
user=$(whoami)
uptime_sec=$(awk '{print int($1)}' /proc/uptime 2>/dev/null)
if [ "$uptime_sec" -ge 3600 ]; then
  uptime_display="$((uptime_sec / 3600))h $(((uptime_sec % 3600) / 60))m"
elif [ "$uptime_sec" -ge 60 ]; then
  uptime_display="$((uptime_sec / 60))m $((uptime_sec % 60))s"
else
  uptime_display="${uptime_sec}s"
fi

kernel=$(uname -r 2>/dev/null || echo "unknown")
packages=$(pacman -Q 2>/dev/null | wc -l || echo 0)

disk_used=$(df -h / 2>/dev/null | awk 'NR==2{print $3}')
disk_total=$(df -h / 2>/dev/null | awk 'NR==2{print $2}')
disk_pct=$(df / 2>/dev/null | awk 'NR==2{print $5}' | tr -d '%')

mem_total=$(awk '/^MemTotal/{printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)
mem_avail=$(awk '/^MemAvailable/{printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)
mem_pct=0
[ "$mem_total" -gt 0 ] && mem_pct=$(( (mem_total - mem_avail) * 100 / mem_total ))

apps_json=""
first=true
while IFS= read -r line; do
  count=$(echo "$line" | awk '{print $1}')
  name=$(echo "$line" | awk '{$1=""; print $0}' | xargs)
  [ -z "$name" ] && continue
  $first && first=false || apps_json+=","
  apps_json+="\"$name\":$count"
done < <(ps --no-headers -eo comm 2>/dev/null | sort | uniq -c | sort -rn | head -6)

cat > "$CACHE" <<EOF
{"hostname":"$hname","user":"$user","uptime":"$uptime_display","kernel":"$kernel","packages":$packages,"disk_used":"$disk_used","disk_total":"$disk_total","disk_pct":$disk_pct,"mem_total":$mem_total,"mem_pct":$mem_pct,"apps":{$apps_json}}
EOF

cat "$CACHE"
