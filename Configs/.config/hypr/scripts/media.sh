#!/usr/bin/env bash

MAX=34
SEP=$'\x1f'
ESO
declare -A ICON=([Playing]=F040A [Paused]=F03E4 [Stopped]=F04DB)

IFS=$SEP read -r status title artist time < <(
  playerctl metadata 2>/dev/null --format \
    "{{status}}$SEP{{title}}$SEP{{artist}}$SEP{{duration(position)}} / {{duration(mpris:length)}}"
)

if [ -z "$status" ]; then
  echo "No song"
  exit 0
fi

fit() {
  local s=${1:0:MAX}
  [ "${#1}" -gt "$MAX" ] && s="${s::-1}…"
  s=${s//&/&amp;}; s=${s//</&lt;}
  echo "${s//>/&gt;}"
}

printf -v icon "\U000${ICON[$status]:-F04DB}"

printf "<span font_size='14pt' weight='bold'>%s</span>\n<span font_size='14pt' alpha='70%%'>%s</span>\n<span font_size='12pt' alpha='55%%'>%s  %s</span>\n" \
  "$(fit "$title")" "$(fit "$artist")" "$icon" "$time"
