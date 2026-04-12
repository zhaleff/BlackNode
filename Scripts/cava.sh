#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: cava.sh
# Description: Installs Cava (Console-based Audio Visualizer for Alsa), a cross-platform
#              audio visualizer that integrates well with Waybar and terminals.
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

yay -S --noconfirm cava

mkdir -p "$HOME/.config/cava"
cp -r "$DOTFILES_CONFIG/cava/"* "$HOME/.config/cava/"
