#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: information.sh
# Description: Displays BlackNode dotfile metadata and performs a live check of
#              every component by verifying its binary in PATH. Shows version,
#              author, licence and a colour-coded installed/missing status per tool.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
WHITE="\033[1;37m"
CYAN="\033[0;36m"
CYAN_B="\033[1;36m"
GRAY="\033[0;90m"
BLUE_B="\033[1;34m"
GREEN="\033[0;32m"
RED="\033[0;31m"

VERSION="1.0.0"

COMPONENTS=(
    "hyprland:Window Manager"
    "waybar:Status Bar"
    "hyprlock:Screen Locker"
    "hypridle:Idle Daemon"
    "hyprshot:Screenshot Tool"
    "rofi:App Launcher"
    "dunst:Notification Daemon"
    "kitty:Terminal Emulator"
    "alacritty:Terminal Emulator"
    "nvim:Text Editor"
    "yazi:File Manager"
    "fastfetch:System Info"
    "cava:Audio Visualiser"
    "clipse:Clipboard Manager"
    "wallust:Colour Scheme Generator"
    "wlogout:Logout Screen"
    "zsh:Shell"
    "awww:Wallpaper Daemon"
    "yay:AUR Helper"
    "flatpak:Flatpak"
)

check() {
    local bin="${1%%:*}"
    local label="${1##*:}"
    if command -v "$bin" &>/dev/null; then
        printf "  ${GREEN}✓${RESET}  ${WHITE}%-20s${RESET} ${GRAY}%s${RESET}\n" "$bin" "$label"
    else
        printf "  ${RED}✗${RESET}  ${GRAY}%-20s  %s${RESET}\n" "$bin" "$label"
    fi
}

echo -e "${CYAN_B}"
cat << 'EOF'
  (()/(       )\ )       (       )       )  ( /( (
   /(_)) (   (()/(   (   )(     (     ( /(  )\()))\   (    (
  (_))   )\ ) /(_))  )\ (()\    )\  ' )(_))(_))/((_)  )\   )\ )
  |_ _| _(_/((_) _| ((_) ((_) _((_)) ((_)_ | |_  (_) ((_) _(_/(
   | | | ' \))|  _|/ _ \| '_|| '  \()/ _` ||  _| | |/ _ \| ' \))
  |___||_||_| |_|  \___/|_|  |_|_|_| \__,_| \__| |_|\___/|_||_|
EOF
echo -e "${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${CYAN}Version     ${GRAY}→  ${WHITE}${VERSION}${RESET}"
echo -e "  ${CYAN}Author      ${GRAY}→  ${WHITE}zhaleff${RESET}"
echo -e "  ${CYAN}Licence     ${GRAY}→  ${WHITE}MIT${RESET}"
echo -e "  ${CYAN}Repository  ${GRAY}→  ${BLUE_B}https://github.com/zhaleff/BlackNode${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${BOLD}${WHITE}Installed components${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""

for component in "${COMPONENTS[@]}"; do
    check "$component"
done

echo ""
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${DIM}${WHITE}Run ${RESET}${CYAN}help.sh${RESET}${DIM}${WHITE} for the full list of available scripts.${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
