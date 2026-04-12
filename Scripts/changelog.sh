#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: changelog.sh
# Description: Displays the BlackNode version history directly in the terminal.
#              Each entry lists version number, release date and a summary of
#              what changed. Update this script with every new release.
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
YELLOW="\033[0;33m"
GREEN="\033[0;32m"

echo -e "${CYAN_B}"
cat << 'EOF'
                                        (
   (       )                            )\ )
   )\   ( /(     )         (  (     (  (()/(       (  (
 (((_)  )\()) ( /(   (     )\))(   ))\  /(_))  (   )\))(
 )\___ ((_)\  )(_))  )\ ) ((_))\  /((_)(_))    )\ ((_))\
((/ __|| |(_)((_)_  _(_/(  (()(_)(_))  | |    ((_) (()(_)
 | (__ | ' \ / _` || ' \))/ _` | / -_) | |__ / _ \/ _` |
  \___||_||_|\__,_||_||_| \__, | \___| |____|\___/\__, |
                          |___/                   |___/
EOF
echo -e "${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${WHITE}Changelog${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${CYAN_B}[1.0.0]${RESET}  ${GRAY}2025${RESET}  ${GREEN}● Initial release${RESET}"
echo ""
echo -e "  ${YELLOW}+${RESET}  ${WHITE}First public release of BlackNode dotfiles${RESET}"
echo -e "  ${YELLOW}+${RESET}  ${WHITE}Modular install scripts for all components${RESET}"
echo -e "  ${YELLOW}+${RESET}  ${WHITE}Hyprland, Waybar, Kitty, Alacritty, Rofi, Dunst${RESET}"
echo -e "  ${YELLOW}+${RESET}  ${WHITE}Hyprlock, Hypridle, Hyprshot${RESET}"
echo -e "  ${YELLOW}+${RESET}  ${WHITE}Yazi, Neovim, Cava, Clipse, Wallust, Wlogout${RESET}"
echo -e "  ${YELLOW}+${RESET}  ${WHITE}Zsh + Powerlevel10k as default shell${RESET}"
echo -e "  ${YELLOW}+${RESET}  ${WHITE}awww as wallpaper daemon (active swww fork)${RESET}"
echo -e "  ${YELLOW}+${RESET}  ${WHITE}Wallpapers stored under ~/.local/share/wallpapers${RESET}"
echo -e "  ${YELLOW}+${RESET}  ${WHITE}Scripts deployed to ~/.local/bin via bins.sh${RESET}"
echo -e "  ${YELLOW}+${RESET}  ${WHITE}GTK 3/4 theming via nwg-look${RESET}"
echo -e "  ${YELLOW}+${RESET}  ${WHITE}update.sh covers pacman and yay in a single pass${RESET}"
echo ""
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${CYAN}Repository  ${GRAY}→  ${BLUE_B}https://github.com/zhaleff/BlackNode${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
