#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: welcome.sh
# Description: Displays the BlackNode welcome banner at the start of the installation.
#              Shows the project ASCII art, author info and a brief overview
#              of what the installer will set up on the system.
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
                                                                                    )
 (  (           (                             )         (   (                )  ( /(        (
 )\))(   '   (  )\             )      (    ( /(       ( )\  )\    )       ( /(  )\())       )\ )   (
((_)()\ )   ))\((_) (   (     (      ))\   )\()) (    )((_)((_)( /(   (   )\())((_)\   (   (()/(  ))\
_(())\_)() /((_)_   )\  )\    )\  ' /((_) (_))/  )\  ((_)_  _  )(_))  )\ ((_)\  _((_)  )\   ((_))/((_)
\ \((_)/ /(_)) | | ((_)((_) _((_)) (_))   | |_  ((_)  | _ )| |((_)_  ((_)| |(_)| \| | ((_)  _| |(_))
 \ \/\/ / / -_)| |/ _|/ _ \| '  \()/ -_)  |  _|/ _ \  | _ \| |/ _` |/ _| | / / | .` |/ _ \/ _` |/ -_)
  \_/\_/  \___||_|\__|\___/|_|_|_| \___|   \__|\___/  |___/|_|\__,_|\__| |_\_\ |_|\_|\___/\__,_|\___|
EOF
echo -e "${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${WHITE}A minimal, modular Hyprland dotfile environment${RESET}"
echo -e "  ${BOLD}${WHITE}Your home in the terminal. Simple, clean, yours.${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "  ${CYAN}Author     ${GRAY}→  ${WHITE}zhaleff${RESET}"
echo -e "  ${CYAN}Version    ${GRAY}→  ${WHITE}1.0.0${RESET}"
echo -e "  ${CYAN}Licence    ${GRAY}→  ${WHITE}MIT${RESET}"
echo -e "  ${CYAN}Repository ${GRAY}→  ${BLUE_B}https://github.com/zhaleff/BlackNode${RESET}"
echo ""
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${DIM}${WHITE}Each component is independent — run only what you need.${RESET}"
echo -e "  ${DIM}${WHITE}Run ${RESET}${CYAN}help.sh${RESET}${DIM}${WHITE} at any time to see all available scripts.${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
