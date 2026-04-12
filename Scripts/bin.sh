#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: bins.sh
# Description: Creates the $HOME/.local/bin directory if it doesn't exist,
#              copies all BlackNode scripts into it and makes them executable.
#              Also ensures $HOME/.local/bin is in PATH via shell profile.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

DOTFILES_BINS="$HOME/BlackNode/Configs/.local/bin"
BIN_DEST="$HOME/.local/bin"

mkdir -p "$BIN_DEST"

cp -r "$DOTFILES_BINS/"* "$BIN_DEST/"
chmod +x "$BIN_DEST"/*

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
fi
