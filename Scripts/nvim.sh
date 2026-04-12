#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: nvim.sh
# Description: Installs Neovim (hyperextensible Vim-based text editor) and deploys
#              its full config from the BlackNode repo, including plugins setup via lazy.nvim.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

DOTFILES_CONFIG="$HOME/BlackNode/Configs/.config"

yay -S --noconfirm neovim

mkdir -p "$HOME/.config/nvim"
cp -r "$DOTFILES_CONFIG/nvim/"* "$HOME/.config/nvim/"
