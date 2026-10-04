#!/usr/bin/env bash

PLAY=""
PAUSE=""

last=""
while true; do
  s="$(playerctl status 2>/dev/null)"
  if [ "$s" != "$last" ]; then
    case "$s" in
      Playing) printf '{"text":"%s","class":"playing","alt":"playing"}\n' "$PAUSE" ;;
      *)       printf '{"text":"%s","class":"paused","alt":"paused"}\n' "$PLAY" ;;
    esac
    last="$s"
  fi
  sleep 0.5
done
