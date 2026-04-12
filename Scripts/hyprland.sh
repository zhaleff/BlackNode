#!/usr/bin/env bash
# https://github.com/zhaleff/BlackNode
# Author: zhaleff
# Copyright (C) 2026

yay -S --noconfirm hyprland xdg-desktop-portal-hyprland

mkdir -p ~/.config/hypr
cp -r ./config/hypr/* ~/.config/hypr/
