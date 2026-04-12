#!/usr/bin/env bash

# https://github.com/zhaleff/BlackNode
# Author: Zhaleff
# Copyright (C) 2026
#
yay -S --noconfirm flatpak

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
