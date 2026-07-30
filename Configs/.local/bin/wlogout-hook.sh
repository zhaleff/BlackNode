#!/usr/bin/env bash
# BlackNode Wlogout Hook — trigger shutdown-ritual before exit
set -euo pipefail

# Run shutdown ritual in background so wlogout isn't blocked
"$(dirname "$0")/shutdown-ritual.sh" &
sleep 2

# Then actually exit
case "${1:-}" in
  shutdown) systemctl poweroff ;;
  reboot)   systemctl reboot ;;
  suspend)  systemctl suspend ;;
  logout)   hyprctl dispatch exit ;;
  hibernate) systemctl hibernate ;;
  *) exit 0 ;;
esac