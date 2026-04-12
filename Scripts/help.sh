#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: help.sh
# Description: Prints a colour-coded reference of every available BlackNode script,
#              organised by category with a one-line description for each one.
#              Intended as a quick in-terminal manual for the full installer suite.
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
MAGENTA="\033[0;35m"

section() {
    echo ""
    echo -e "  ${BOLD}${YELLOW}$1${RESET}"
    echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
}

entry() {
    printf "  ${CYAN}%-22s${RESET}${GRAY}→  ${RESET}${DIM}${WHITE}%s${RESET}\n" "$1" "$2"
}

echo -e "${CYAN_B}"
cat << 'EOF'
      )                                               )
   ( /(       (            (   (                )  ( /(        (
   )\())   (  )\         ( )\  )\    )       ( /(  )\())       )\ )   (
  ((_)\   ))\((_)`  )    )((_)((_)( /(   (   )\())((_)\   (   (()/(  ))\
   _((_) /((_)_  /(/(   ((_)_  _  )(_))  )\ ((_)\  _((_)  )\   ((_))/((_)
  | || |(_)) | |((_)_\   | _ )| |((_)_  ((_)| |(_)| \| | ((_)  _| |(_))
  | __ |/ -_)| || '_ \)  | _ \| |/ _` |/ _| | / / | .` |/ _ \/ _` |/ -_)
  |_||_|\___||_|| .__/   |___/|_|\__,_|\__| |_\_\ |_|\_|\___/\__,_|\___|
              |_|
EOF
echo -e "${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${BOLD}${WHITE}Available Scripts — BlackNode Dotfiles${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"

section "DOCUMENTATION"
entry "welcome.sh"       "Displays the BlackNode welcome banner"
entry "information.sh"   "Shows version, author and live component status"
entry "changelog.sh"     "Prints the full BlackNode changelog"
entry "help.sh"          "Shows this reference list"

section "CORE"
entry "yay.sh"           "Installs the yay AUR helper from source"
entry "flatpak.sh"       "Installs Flatpak and adds the Flathub remote"
entry "update.sh"        "Full system update — pacman then yay then flatpak"
entry "bins.sh"          "Deploys BlackNode scripts to ~/.local/bin"

section "WINDOW MANAGER"
entry "hyprland.sh"      "Installs Hyprland and deploys its config"
entry "hyprlock.sh"      "Installs hyprlock + hypridle and deploys both configs"
entry "hyprshot.sh"      "Installs hyprshot and creates ~/Pictures/Screenshots"

section "BAR & LAUNCHER"
entry "waybar.sh"        "Installs Waybar and deploys its config"
entry "rofi.sh"          "Installs rofi-wayland and deploys its config"

section "TERMINAL & SHELL"
entry "kitty.sh"         "Installs Kitty terminal and deploys its config"
entry "alacritty.sh"     "Installs Alacritty terminal and deploys its config"
entry "zsh.sh"           "Installs Zsh + Powerlevel10k and sets it as default shell"

section "TOOLS"
entry "nvim.sh"          "Installs Neovim and deploys its full config"
entry "yazi.sh"          "Installs Yazi file manager with all preview dependencies"
entry "fastfetch.sh"     "Installs Fastfetch and deploys its config"
entry "cava.sh"          "Installs Cava audio visualiser and deploys its config"
entry "clipse.sh"        "Installs Clipse clipboard manager and deploys its config"
entry "dunst.sh"         "Installs Dunst notification daemon and deploys its config"
entry "wlogout.sh"       "Installs wlogout and deploys its layout and styles"

section "THEMING"
entry "wallust.sh"       "Installs wallust colour-scheme generator and deploys its config"
entry "wallpaper.sh"     "Moves wallpapers to ~/.local/share/wallpapers"
entry "gtk.sh"           "Installs nwg-look and deploys GTK 3/4 theme configs"
entry "awww.sh"          "Installs awww wallpaper daemon (active swww fork)"

echo ""
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "  ${DIM}${WHITE}Each script is fully independent — run only what you need.${RESET}"
echo -e "  ${CYAN}Repository  ${GRAY}→  ${BLUE_B}https://github.com/zhaleff/BlackNode${RESET}"
echo -e "${GRAY}  ──────────────────────────────────────────────────────────────────────────────────${RESET}"
echo ""
