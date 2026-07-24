#!/usr/bin/env bash
# BlackNode Shutdown Ritual — cierre consciente con reconocimiento
set -euo pipefail

ASSETS="$HOME/.config/dunst/assets"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/blacknode"
CACHE_MSGS="$CACHE_DIR/psych-messages.json"
REPO_MSGS="https://raw.githubusercontent.com/zhaleff/blacknode/main/Configs/.local/share/blacknode/psych-messages.json"
STATE_DIR="$HOME/.local/share/blacknode"
IDENTITY="$STATE_DIR/identity.json"
PREF="$STATE_DIR/session_profile"
mkdir -p "$CACHE_DIR" "$STATE_DIR"

fetch_messages() {
  if [[ -f "$CACHE_MSGS" ]] && [[ $(($(date +%s) - $(stat -c %Y "$CACHE_MSGS" 2>/dev/null || echo 0))) -lt 3600 ]]; then
    cat "$CACHE_MSGS"; return
  fi
  curl -sf "$REPO_MSGS" -o "$CACHE_MSGS.tmp" && mv "$CACHE_MSGS.tmp" "$CACHE_MSGS" && cat "$CACHE_MSGS" || cat "$CACHE_MSGS" 2>/dev/null || echo '{}'
}

pick() {
  echo "$1" | python3 -c "
import sys, json, random, string
try:
    data = json.load(sys.stdin)
    if isinstance(data, list) and data:
        print(random.choice(data))
except: pass
" 2>/dev/null
}

period_title() {
  case "$1" in
    dawn)     echo "Cierre de madrugada" ;;
    morning)  echo "Cierre de mañana" ;;
    afternoon) echo "Cierre de tarde" ;;
    evening)  echo "Cierre de jornada" ;;
    night)    echo "Cierre nocturno" ;;
    *)        echo "Cierre consciente" ;;
  esac
}

main() {
  local msgs
  msgs=$(fetch_messages)

  local hour_utc period
  hour_utc=$(date -u +%H)
  hour_utc=$((10#$hour_utc))
       if [[ $hour_utc -le 4 ]]; then period=dawn
  elif [[ $hour_utc -le 7 ]]; then period=dawn
  elif [[ $hour_utc -le 11 ]]; then period=morning
  elif [[ $hour_utc -le 13 ]]; then period=afternoon
  elif [[ $hour_utc -le 17 ]]; then period=afternoon
  elif [[ $hour_utc -le 21 ]]; then period=evening
  else period=night
  fi

  local profile=light
  [[ -f "$PREF" ]] && grep -qi "coding\|study\|deep\|work" "$PREF" 2>/dev/null && profile=deep_work

  local rawinfo
  rawinfo=$(echo "$msgs" | python3 -c "
import sys, json, random
d = json.load(sys.stdin)
block = d.get('shutdown', {}).get('$profile', {})
if isinstance(block, dict):
    pool = block.get('$period') or block.get('any')
    if isinstance(pool, list) and pool:
        print(random.choice(pool))
" 2>/dev/null)

  if [[ -z "$rawinfo" ]]; then
    rawinfo=$(echo "$msgs" | python3 -c "
import sys, json, random
d = json.load(sys.stdin)
block = d.get('shutdown', {}).get('light', {})
if isinstance(block, dict):
    pool = block.get('$period') or block.get('any')
    if isinstance(pool, list) and pool:
        print(random.choice(pool))
" 2>/dev/null)
  fi

  local streak=0 closes=0
  if [[ -f "$IDENTITY" ]]; then
    streak=$(python3 -c "import json; d=json.load(open('$IDENTITY')); print(d.get('streak_current',0))" 2>/dev/null || echo 0)
    closes=$(python3 -c "import json; d=json.load(open('$IDENTITY')); print(d.get('clean_closes',0))" 2>/dev/null || echo 0)
  fi

  local extras=""
  if [[ $streak -gt 0 ]] && [[ $((streak % 7)) -eq 0 || $streak -eq 3 || $streak -eq 14 || $streak -eq 30 || $streak -eq 60 || $streak -eq 100 ]]; then
    local sm
    sm=$(echo "$msgs" | python3 -c "
import sys, json, random
d = json.load(sys.stdin)
pool = d.get('shutdown', {}).get('streak', [])
if pool: print(random.choice(pool))
" 2>/dev/null)
    sm="${sm//\{streak\}/$streak}"
    extras="$sm"
  fi

  local intention=""
  local ifile="$STATE_DIR/psych/intention.txt"
  if [[ -f "$ifile" ]]; then
    intention=$(cat "$ifile")
    local im
    im=$(echo "$msgs" | python3 -c "
import sys, json, random
d = json.load(sys.stdin)
pool = d.get('shutdown', {}).get('intention', [])
if pool: print(random.choice(pool))
" 2>/dev/null)
    im="${im//\{intention\}/$intention}"
    extras="$extras  $im"
  fi

  local icon="$ASSETS/shutdown-done.svg"
  local title
  title=$(period_title "$period")
  local body="$rawinfo"
  [[ -n "$extras" ]] && body="$body\n\n$extras"

  dunstify -a "BlackNode" -i "$icon" -t 10000 "$title" "$body"

  if [[ -f "$IDENTITY" ]]; then
    python3 -c "
import json
p = '$IDENTITY'
d = json.load(open(p))
d['clean_closes'] = d.get('clean_closes',0) + 1
d['streak_current'] = d.get('streak_current',0) + 1
if d['streak_current'] > d.get('streak_longest',0):
    d['streak_longest'] = d['streak_current']
d['last_close'] = '$(date -u -Iseconds)'
json.dump(d, open(p,'w'), indent=2)
" 2>/dev/null || true
  fi
}

main "$@"