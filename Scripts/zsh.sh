#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: zsh.sh
# Description: Installs Zsh with autosuggestions and syntax highlighting plugins,
#              then installs Powerlevel10k as the prompt theme. Deploys both configs
#              from the BlackNode repo and sets Zsh as the default shell for the
#              current user via chsh.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

DOTFILES_CONFIG="$HOME/BlackNode/Configs/.config"

sudo pacman -S --noconfirm zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
yay -S --noconfirm zsh-theme-powerlevel10k-git

mkdir -p "$HOME/.config/zsh"
mkdir -p "$HOME/.config/powerlevel10k"

cp -r "$DOTFILES_CONFIG/zsh/"* "$HOME/.config/zsh/"
cp -r "$DOTFILES_CONFIG/powerlevel10k/"* "$HOME/.config/powerlevel10k/"

chsh -s "$(which zsh)"
