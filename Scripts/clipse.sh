#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: clipse.sh
# Description: Installs Clipse, a TUI clipboard manager for Wayland that stores
#              clipboard history persistently and integrates with rofi/wofi for search.
#              Deploys its config from the BlackNode repo.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

DOTFILES_CONFIG="$HOME/BlackNode/Configs/.config"

yay -S --noconfirm clipse

mkdir -p "$HOME/.config/clipse"
cp -r "$DOTFILES_CONFIG/clipse/"* "$HOME/.config/clipse/"
