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
  configs/.zshrc          ← entry point (symlinked)
  plugins/                ← clone plugin repos here

~/.config/waybar/         ← Waybar
  Layouts/                ← bar layout presets (blacknode, blacknode-2..8, compact, essential, full, minimal)
  Profiles/               ← environment profiles (music, study, coding, astronomy, default)

~/.config/matugen/        ← colour generation
  config.toml             ← template configuration
  templates/              ← custom templates (hyprlock, etc.)
```

## BlackNode software layout (repo)

```
BlackNode/                ← repo root
  Configs/.config/        ← dotfiles symlinked to ~/.config
  Configs/.local/bin/     ← shell entrypoints
  src/brain/              ← blacknode-brain Rust engine (Cargo)
  scripts/                ← install / linkdots / health / failed
  docs/                   ← this documentation
  assets/                 ← logo and imagery
  version.json            ← ecosystem + component versions
```

The `blacknode` CLI is the front door to the ecosystem (see ARCHITECTURE.md).

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
