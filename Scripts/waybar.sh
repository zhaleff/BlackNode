#!/usr/bin/env bash

# https://github.com/zhaleff/BlackNode
# Author: Zhaleff
# Copyright (C) 2026

yay -S --noconfirm waybar

mkdir -p ~/.config/waybar
cp -r ./config/waybar/* ~/.config/waybar/
