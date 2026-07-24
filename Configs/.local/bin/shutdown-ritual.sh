#!/usr/bin/env bash
# BlackNode Shutdown Ritual — cierre consciente con reconocimiento
# Detecta apagado/logout/suspend, elige mensaje según sesión UTC, muestra notificación
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

get_msg() {
  local msgs=$1 key=$2 sub=$3
  echo "$msgs" | python3 -c "
import sys, json, random
d = json.load(sys.stdin)
msgs = d.get('$key', {})
if '$sub' in msgs:
    pool = msgs['$sub'] if isinstance(msgs['$sub'], list) else msgs['$sub']
    if isinstance(pool, list):
        print(random.choice(pool))
    elif isinstance(pool, dict):
        print(random.choice(list(pool.values())))
" 2>/dev/null || echo ""
}

get_zone_messages() {
  local msgs=$1 key=$2 profile=$3 period=$4
  echo "$msgs" | python3 -c "
import sys, json, random
d = json.load(sys.stdin)
block = d.get('$key', {}).get('$profile', {})
if isinstance(block, dict):
    pool = block.get('any') or block.get('$period')
    if isinstance(pool, list) and pool:
        print(random.choice(pool))
        return
    keys = [k for k in block if isinstance(block[k], list) and block[k]]
    if keys:
        print(random.choice(block[random.choice(keys)]))
" 2>/dev/null || echo ""
}

main() {
  local msgs
  msgs=$(fetch_messages)

  local hour_utc zone
  hour_utc=$(date -u +%H)
  hour_utc=$((10#$hour_utc))
  if [[ $hour_utc -le 4 ]]; then zone=dawn
  elif [[ $hour_utc -le 7 ]]; then zone=dawn
  elif [[ $hour_utc -le 11 ]]; then zone=morning
  elif [[ $hour_utc -le 13 ]]; then zone=afternoon
  elif [[ $hour_utc -le 17 ]]; then zone=afternoon
  elif [[ $hour_utc -le 21 ]]; then zone=evening
  else zone=night
  fi

  local deep=false
  [[ -f "$PREF" ]] && grep -qi "coding\|study\|deep\|work" "$PREF" 2>/dev/null && deep=true

  local profile_type=light
  $deep && profile_type=deep_work

  local icon="$ASSETS/shutdown-done.svg"
  local title body

  body=$(get_zone_messages "$msgs" "shutdown" "$profile_type" "$zone")
  if [[ -z "$body" ]]; then
    body=$(get_zone_messages "$msgs" "shutdown" "light" "$zone")
  fi

  # check streak
  local streak=0
  if [[ -f "$IDENTITY" ]]; then
    streak=$(python3 -c "import json; d=json.load(open('$IDENTITY')); print(d.get('streak_current',0))" 2>/dev/null || echo 0)
  fi

  # bonus streak message if milestone
  if [[ $streak -gt 0 && $((streak % 7)) -eq 0 ]] || [[ $streak -eq 3 ]] || [[ $streak -eq 14 ]] || [[ $streak -eq 30 ]] || [[ $streak -eq 60 ]] || [[ $streak -eq 100 ]]; then
    local streak_msg
    streak_msg=$(get_msg "$msgs" "shutdown" "streak")
    streak_msg="${streak_msg//\{streak\}/$streak}"
    body="$body • $streak_msg"
  fi

  local parting
  parting=$(get_msg "$msgs" "shutdown" "parting")
  body="$body  $parting"

  # Store intention if exists
  local intention_file="$STATE_DIR/psych/intention.txt"
  if [[ -f "$intention_file" ]]; then
    local intention
    intention=$(cat "$intention_file")
    local intent_msg
    intent_msg=$(get_msg "$msgs" "shutdown" "intention")
    intent_msg="${intent_msg//\{intention\}/$intention}"
    body="$body  $intent_msg"
  fi

  title=$(get_msg "$msgs" "shutdown" "parting")

  dunstify -a "BlackNode" -i "$icon" -t 10000 "$title" "$body"

  # Increment clean close counter
  if [[ -f "$IDENTITY" ]]; then
    python3 -c "
import json, os
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