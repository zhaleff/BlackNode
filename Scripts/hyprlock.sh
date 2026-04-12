#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: hyprlock.sh
# Description: Installs hyprlock (GPU-accelerated screen locker) and hypridle
#              (idle management daemon) from the official Arch extra repo.
#              Deploys both configs from the BlackNode repo.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

DOTFILES_CONFIG="$HOME/BlackNode/Configs/.config"

sudo pacman -S --noconfirm hyprlock hypridle

mkdir -p "$HOME/.config/hypr"
cp "$DOTFILES_CONFIG/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
cp "$DOTFILES_CONFIG/hypr/hypridle.conf" "$HOME/.config/hypr/hypridle.conf"
