#!/usr/bin/env bash
# https://github.com/zhaleff/BlackNode
# Author: Zhaleff
# Copyright (C) 2026

sudo pacman -S --needed --noconfirm git base-devel

git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
cd ~
rm -rf /tmp/yay
