# Reference

BlackNode is a set of dotfiles for Arch Linux + Hyprland. It uses Material You colour generation (matugen), modular Rofi themes, Lua-based Hyprland configuration, and a structured ZSH setup.

## Architecture

```
~/.config/hypr/          ← Hyprland config (Lua)
  settings/overrides.lua ← runtime overrides (modified by Config HUD)
  settings/keybinds.lua  ← keybindings
  settings/input.lua     ← input devices
  settings/rules.lua     ← window rules

~/.config/rofi/           ← Rofi (modular themes)
  shared/                 ← shared theme files
  scripts/                ← sidebar scripts
  styles/                 ← per-feature theme wrappers

~/.config/zsh/            ← ZSH config (symlinked to BlackNode)
  modules/                ← modular config files
  configs/.zshrc          ← entry point
  plugins/                ← clone plugin repos here

~/.config/waybar/         ← Waybar
  Layouts/                ← bar layout presets (blacknode, minimal, full, dev, compact)

~/.config/matugen/        ← colour generation
  config.toml             ← template configuration
  templates/              ← custom templates (hyprlock, etc.)
```

## Dependencies

See `PACKAGES.md`.

## Installation

See `INSTALLATION.md`.

## Scripts

| Script | Purpose |
|--------|---------|
| `Scripts/install.sh` | Automated installer with pre-flight checks, NVIDIA setup, rollback |
| `Scripts/linkdots.sh` | Symlink Configs/ to ~/.config/ with automatic backup |
| `Scripts/health.sh` | System health diagnostic (services, GPU, resources, config integrity) |
| `Scripts/failed.sh` | Install log analyser with 25+ error patterns and fixes |
