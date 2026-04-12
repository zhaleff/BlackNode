#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: wallpaper.sh
# Description: Interactively asks the user where their wallpapers are located,
#              then moves them to the standard $HOME/.local/share/wallpapers directory.
#              This is the canonical wallpaper location used by BlackNode.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

WALLPAPER_DEST="$HOME/.local/share/wallpapers"

mkdir -p "$WALLPAPER_DEST"

read -rp "Where are your wallpapers located? (full path or relative to \$HOME): " USER_PATH

if [[ "$USER_PATH" != /* ]]; then
    USER_PATH="$HOME/$USER_PATH"
fi

if [[ ! -d "$USER_PATH" ]]; then
    echo "The path '$USER_PATH' does not exist or is not a directory."
    exit 1
fi

mv "$USER_PATH"/* "$WALLPAPER_DEST"/

echo "Wallpapers moved to $WALLPAPER_DEST"
