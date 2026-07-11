#!/usr/bin/env bash
CACHE="$HOME/.config/quickshell/dashboard/cache/activity.json"

if [ -f "$CACHE" ] && [ "$(find "$CACHE" -mmin -1 2>/dev/null)" ]; then
  cat "$CACHE"
  exit 0
fi

events_json=""
first=true

add_event() {
  local time="$1" icon="$2" text="$3"
  text="$(echo "$text" | sed 's/"/\\"/g')"
  $first && first=false || events_json+=","
  events_json+="{\"time\":\"$time\",\"icon\":\"$icon\",\"text\":\"$text\"}"
}

now=$(date +%s)
boot=$(awk '{print int($1)}' /proc/uptime 2>/dev/null)
boot_ts=$((now - boot))
boot_time=$(date -d "@$boot_ts" +%H:%M 2>/dev/null || echo "00:00")
add_event "$boot_time" "󰒋" "System booted"

if command -v journalctl &>/dev/null; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    msg=$(echo "$line" | awk '{$1=$2=$3=$4=$5=$6=""; print $0}' | xargs)
    ts=$(echo "$line" | awk '{print $3}')
    time_only=$(date -d "$ts" +%H:%M 2>/dev/null || echo "$ts")
    icon="󰧨"
    case "$msg" in
      *suspend*|*resume*) icon="󰤄" ;;
      *ssh*|*sshd*) icon="󰒋" ;;
      *error*|*fail*) icon="󰅙" ;;
      *Network*|*network*|*dhcp*|*wlan*) icon="󰖩" ;;
      *usb*|*USB*) icon="󰌘" ;;
      *battery*|*power*) icon="󰁹" ;;
      *dock*|*undock*) icon="󰏖" ;;
      *kitty*|*alacritty*|*terminal*) icon="󰞇" ;;
      *firefox*|*chromium*|*brave*) icon="󰈹" ;;
      *spotify*|*player*) icon="󰓇" ;;
    esac
    add_event "$time_only" "$icon" "$msg"
  done < <(journalctl --no-pager -n 20 2>/dev/null | grep -v "  --  Boot")
fi

cat > "$CACHE" <<EOF
{"events":[$events_json]}
EOF

cat "$CACHE"
