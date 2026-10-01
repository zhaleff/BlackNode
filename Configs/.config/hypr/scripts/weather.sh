#!/usr/bin/env bash

LAT="13.67"
LON="-89.28"
TTL=900
CACHE="$HOME/.cache/hyprlock/weather.json"
URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m,apparent_temperature,weather_code,is_day&timezone=auto"

# WMO code -> "day icon|night icon|description" (hex = Material Design codepoints)
declare -A WMO=(
  [0]="F0599|F0594|Clear"
  [1]="F0595|F0F31|Mostly clear"
  [2]="F0595|F0F31|Partly cloudy"
  [3]="F0590|F0590|Overcast"
  [45]="F0591|F0591|Fog"
  [48]="F0591|F0591|Fog"
  [51]="F0597|F0597|Drizzle"
  [53]="F0597|F0597|Drizzle"
  [55]="F0597|F0597|Drizzle"
  [56]="F0597|F0597|Freezing drizzle"
  [57]="F0597|F0597|Freezing drizzle"
  [61]="F0597|F0597|Rain"
  [63]="F0597|F0597|Rain"
  [65]="F0596|F0596|Heavy rain"
  [66]="F0597|F0597|Freezing rain"
  [67]="F0596|F0596|Freezing rain"
  [71]="F0598|F0598|Snow"
  [73]="F0598|F0598|Snow"
  [75]="F0598|F0598|Heavy snow"
  [77]="F0598|F0598|Snow grains"
  [80]="F0596|F0596|Showers"
  [81]="F0596|F0596|Showers"
  [82]="F0596|F0596|Violent showers"
  [85]="F0598|F0598|Snow showers"
  [86]="F0598|F0598|Snow showers"
  [95]="F0593|F0593|Thunderstorm"
  [96]="F0593|F0593|Thunderstorm"
  [99]="F0593|F0593|Thunderstorm"
)

mkdir -p "${CACHE%/*}"

# The refresh is deliberately fire-and-forget on failure: a stale cache is
# better than an empty lock screen, so the old file is only replaced on success.
age=$(( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))
if [ "$age" -gt "$TTL" ]; then
  curl -sf --max-time 8 "$URL" -o "$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"
fi

[ -s "$CACHE" ] || exit 0

read -r temp feels code day < <(
  jq -r '[.current.temperature_2m, .current.apparent_temperature,
          .current.weather_code, .current.is_day] | @tsv' "$CACHE"
)

# Unmapped codes fall back to a generic entry instead of printing nothing
IFS='|' read -r icon_day icon_night desc <<< "${WMO[$code]:-F0590|F0590|Unknown}"
[ "$day" = 1 ] && icon=$icon_day || icon=$icon_night

# Pango markup lets one label carry a big icon and smaller text, so no
# second label is needed. The \U escape needs a UTF-8 locale.
printf "<span font_size='36pt'>\U000$icon</span>  <span font_size='26pt'>%.0f°C</span>\n" "$temp"
printf "<span font_size='13pt' alpha='70%%'>%s · Feels like %.0f°C</span>\n" "$desc" "$feels"
