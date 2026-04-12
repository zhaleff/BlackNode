#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: yazi.sh
# Description: Installs Yazi, a blazing-fast terminal file manager written in Rust,
#              along with its optional dependencies for previews and deploys its config
#              from the BlackNode repo.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

DOTFILES_CONFIG="$HOME/BlackNode/Configs/.config"

yay -S --noconfirm yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide imagemagick

mkdir -p "$HOME/.config/yazi"
cp -r "$DOTFILES_CONFIG/yazi/"* "$HOME/.config/yazi/"
