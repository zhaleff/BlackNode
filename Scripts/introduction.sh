#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: introduction.sh
# Description: Introduces the BlackNode environment to the user. Explains the
#              philosophy, components and general structure of the dotfile suite.
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

echo -e "${CYAN_B}"
cat << 'EOF'
 (
 )\ )           )            (                  )
(()/(        ( /( (          )\ )   (        ( /( (
 /(_)) (     )\()))(    (   (()/(  ))\   (   )\()))\   (    (
(_))   )\ ) (_))/(()\   )\   ((_))/((_)  )\ (_))/((_)  )\   )\ )
|_ _| _(_/( | |_  ((_) ((_)  _| |(_))(  ((_)| |_  (_) ((_) _(_/(
 | | | ' \))|  _|| '_|/ _ \/ _` || || |/ _| |  _| | |/ _ \| ' \))
|___||_||_|  \__||_|  \___/\__,_| \_,_|\__|  \__| |_|\___/|_||_|
EOF
echo -e "${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${WHITE}Welcome to BlackNode${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${DIM}${WHITE}BlackNode is a minimal, modular Hyprland-based desktop environment built${RESET}"
echo -e "  ${DIM}${WHITE}on Arch Linux. It is designed to be clean, fast and fully customisable.${RESET}"
echo -e "  ${DIM}${WHITE}Every component has been chosen deliberately — nothing is installed that${RESET}"
echo -e "  ${DIM}${WHITE}does not serve a clear purpose.${RESET}"
echo ""
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${WHITE}Philosophy${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${DIM}${WHITE}BlackNode follows one rule: modularity. Every script installs exactly one${RESET}"
echo -e "  ${DIM}${WHITE}thing and deploys its configuration. Nothing more. You decide what goes${RESET}"
echo -e "  ${DIM}${WHITE}on your machine — run only the scripts you actually need.${RESET}"
echo ""
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${WHITE}What is included${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${CYAN}Window Manager   ${GRAY}→  ${WHITE}Hyprland — tiling Wayland compositor${RESET}"
echo -e "  ${CYAN}Status Bar       ${GRAY}→  ${WHITE}Waybar — fully configurable bar${RESET}"
echo -e "  ${CYAN}Terminal         ${GRAY}→  ${WHITE}Kitty and Alacritty — GPU-accelerated emulators${RESET}"
echo -e "  ${CYAN}Shell            ${GRAY}→  ${WHITE}Zsh with Powerlevel10k prompt${RESET}"
echo -e "  ${CYAN}Launcher         ${GRAY}→  ${WHITE}Rofi — application launcher for Wayland${RESET}"
echo -e "  ${CYAN}Notifications    ${GRAY}→  ${WHITE}Dunst — lightweight notification daemon${RESET}"
echo -e "  ${CYAN}Lockscreen       ${GRAY}→  ${WHITE}Hyprlock with Hypridle for idle management${RESET}"
echo -e "  ${CYAN}File Manager     ${GRAY}→  ${WHITE}Yazi — blazing-fast terminal file manager${RESET}"
echo -e "  ${CYAN}Editor           ${GRAY}→  ${WHITE}Neovim — extensible modal text editor${RESET}"
echo -e "  ${CYAN}Theming          ${GRAY}→  ${WHITE}Wallust generates colour schemes from wallpapers${RESET}"
echo -e "  ${CYAN}Wallpapers       ${GRAY}→  ${WHITE}awww — GPU-accelerated Wayland wallpaper daemon${RESET}"
echo -e "  ${CYAN}Clipboard        ${GRAY}→  ${WHITE}Clipse — persistent clipboard history for Wayland${RESET}"
echo -e "  ${CYAN}Audio            ${GRAY}→  ${WHITE}Cava — terminal audio visualiser${RESET}"
echo -e "  ${CYAN}Logout           ${GRAY}→  ${WHITE}Wlogout — clean session management screen${RESET}"
echo ""
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${WHITE}Getting started${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${DIM}${WHITE}Clone the repository, navigate to the scripts folder and run${RESET}"
echo -e "  ${DIM}${WHITE}the components you want one by one. Start with${RESET} ${CYAN}yay.sh${RESET}${DIM}${WHITE} if you do${RESET}"
echo -e "  ${DIM}${WHITE}not have an AUR helper yet, then proceed in any order you prefer.${RESET}"
echo ""
echo -e "  ${CYAN}Repository  ${GRAY}→  ${BLUE_B}https://github.com/zhaleff/BlackNode${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
