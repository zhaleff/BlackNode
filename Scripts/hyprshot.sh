#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: hyprshot.sh
# Description: Installs hyprshot, a utility for taking screenshots in Hyprland
#              using mouse selection, window capture or monitor capture.
#              Available in the official Arch extra repo, no AUR needed.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

sudo pacman -S --noconfirm hyprshot

mkdir -p "$HOME/Pictures/Screenshots"
