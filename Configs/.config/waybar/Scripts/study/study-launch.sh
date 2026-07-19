#!/usr/bin/env bash
# Launches Study-profile applications based on the argument.
# study-launch.sh notes|docs|browser|code

case "${1:-}" in
  notes)
    if command -v obsidian &>/dev/null; then
      obsidian & disown
    elif command -v nvim &>/dev/null; then
      kitty --title "Notes" nvim ~/Notes & disown
    else
      notify-send "Study" "No notes app found"
    fi
    ;;
  docs)
    if command -v zathura &>/dev/null; then
      zathura & disown
    elif command -v pcmanfm &>/dev/null; then
      pcmanfm ~ & disown
    else
      xdg-open ~ & disown
    fi
    ;;
  browser)
    if command -v firefox &>/dev/null; then
      firefox & disown
    else
      xdg-open "https://www.wikipedia.org/" & disown
    fi
    ;;
  code)
    if command -v nvim &>/dev/null; then
      kitty --title "Practice" nvim & disown
    else
      kitty & disown
    fi
    ;;
  *)
    notify-send "Study" "Unknown launch target: ${1:-none}"
    ;;
esac
