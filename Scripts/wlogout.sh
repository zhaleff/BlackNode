#!/usr/bin/env bash
# Project: BlackNode Dotfiles
# Script: wallust.sh
# Description: Installs wallust, a tool that generates color schemes from wallpapers
#              and applies them system-wide (Waybar, terminals, etc). Deploys its
#              config from the BlackNode repo.
# Author: zhaleff
# Repository: https://github.com/zhaleff/BlackNode
# License: MIT
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files, to deal in the Software
# without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to do so.

DOTFILES_CONFIG="$HOME/BlackNode/Configs/.config"

yay -S --noconfirm wlogout

cp -r ~/BlackNode/Configs/.config/wlogout/ ~/.config/
