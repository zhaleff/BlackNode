#!/usr/bin/env bash

KEYBOARD=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .name')
LAYOUT=$(hyprctl devices -j | jq -r --arg kb "$KEYBOARD" '.keyboards[] | select(.name == $kb) | .active_keymap')

if [[ "$LAYOUT" == *"Spanish"* ]]; then
  echo '{"text": "󰌌", "tooltip": "Spanish layout — click to switch"}'
else
  echo '{"text": "󰌌", "tooltip": "English layout — click to switch"}'
fi
