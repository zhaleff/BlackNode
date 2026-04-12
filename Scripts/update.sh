#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: update.sh
# Description: Full system update script. Runs updates sequentially across all
#              package managers present on the system: pacman (official repos),
#              yay (AUR) and flatpak (Flathub). Each step is skipped gracefully
#              if the tool is not installed on the current system.
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
WHITE="\033[1;37m"
CYAN="\033[0;36m"
CYAN_B="\033[1;36m"
GRAY="\033[0;90m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"

step() {
    echo -e "\n${CYAN_B}==> ${BOLD}${WHITE}$1${RESET}"
}

ok() {
    echo -e "${GREEN}  ✓  ${WHITE}$1${RESET}"
}

skip() {
    echo -e "${GRAY}  –  $1 not found, skipping.${RESET}"
}

echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${WHITE}BlackNode — System Update${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"

step "pacman — official repositories"
sudo pacman -Syu --noconfirm
ok "pacman updated"

step "yay — AUR packages"
if command -v yay &>/dev/null; then
    yay -Syu --noconfirm
    ok "yay updated"
else
    skip "yay"
fi

step "flatpak — Flathub"
if command -v flatpak &>/dev/null; then
    flatpak update -y
    ok "flatpak updated"
else
    skip "flatpak"
fi

echo ""
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${GREEN}✓  ${BOLD}${WHITE}System fully updated.${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
