#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: awww.sh
# Description: Installs awww, the active fork of swww, a wallpaper daemon for Wayland
#              with GPU-accelerated transitions. No .config directory required;
#              awww-daemon is launched at session start via Hyprland's exec-once.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

yay -S --noconfirm awww

mkdir -p "$HOME/.local/share/wallpapers"
