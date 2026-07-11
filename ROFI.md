<h1 align="center">BlackNode · bn-menu</h1>

<div align="center">
  <p>
    <a href="#"><img src="https://img.shields.io/badge/scripts-19-blue?style=for-the-badge&logo=rofi&logoColor=white&labelColor=302D41&color=89B4FA" alt="Scripts"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/themes-33-green?style=for-the-badge&logo=files&logoColor=white&labelColor=302D41&color=A6E3A1" alt="Themes"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/M3-Material%20You-F9E2AF?style=for-the-badge&logo=materialdesign&logoColor=white&labelColor=302D41" alt="M3"></a>&nbsp;&nbsp;
    <a href="#"><img src="https://img.shields.io/badge/matugen-automatic-CBA6F7?style=for-the-badge&logo=colors&logoColor=white&labelColor=302D41" alt="Matugen"></a>
  </p>
</div>

Hello.  This document explains the rofi menu system in BlackNode — what it is, how it is structured, and how to use it.

It covers two separate but complementary interfaces: **bn-menu** (the main hub with icon + text items) and **rofi sidebars** (icon-only panels on the right edge of the screen).  Both pull colors from the same Material You palette generated automatically from your wallpaper via matugen.


## Table of Contents
- [The Two Interfaces](#the-two-interfaces)
- [Theme Architecture](#theme-architecture)
- [Sidebar Scripts](#sidebar-scripts)
- [Quick Config HUD](#quick-config-hud)
- [bn-menu Submenus](#bn-menu-submenus)
- [Development Rules](#development-rules)


## The Two Interfaces

| Interface | Access | Style | Lines / Items |
|-----------|--------|-------|---------------|
| **bn-menu** | `SUPER + SPACE` | Centered 440×640 window, icon + text, search bar | 15 items |
| **Sidebars** | Keybinds (WiFi, BT, audio, etc.) | 100px-wide right panel, icon-only, no search | 3–6 items |

Both use the same color tokens and the same shared theme files — the only difference is layout and content.


## Theme Architecture

Everything is modular.  No standalone themes.

```
~/.config/rofi/
├── colors.rasi          ← M3 palette from matugen (47 tokens)
├── menu.rasi            ← bn-menu theme (440×640, centered, search)
├── submenu.rasi         ← bn-menu submenu theme (380px, 6 lines)
├── shared/
│   ├── config.rasi      ← Base config (font, scrollbar, sidebar-mode)
│   ├── menu.rasi        ← Sidebar bundle (imports colors + config + sidebar)
│   ├── sidebar.rasi     ← Sidebar layout (100px east, icon-only, feather font)
│   ├── list.rasi        ← Centered list dialog (440px, 28px radius, search)
│   ├── input-dialog.rasi← Input dialog (420px, 24px radius)
│   ├── dialog.rasi      ← Generic dialog
│   └── grid.rasi        ← Grid layout
└── styles/              ← Per-feature themes importing from shared/
    ├── wifi-list.rasi       (6  lines, imports list.rasi)
    ├── bluetooth-list.rasi  (6  lines, imports list.rasi)
    ├── notes-list.rasi      (20 lines, imports list.rasi)
    ├── search-list.rasi     (20 lines, imports list.rasi)
    ├── audio-list.rasi      (46 lines, imports list.rasi)
    ├── notes-input.rasi     (10 lines, imports input-dialog.rasi)
    ├── search-input.rasi    (10 lines, imports input-dialog.rasi)
    ├── config-list.rasi     (wrapper for shared/list.rasi)
    └── ... legacy refactored themes
```

The rule: every `-list.rasi` imports `shared/list.rasi` with **no width, font, padding, or lines overrides**.  Every `-input.rasi` imports `shared/input-dialog.rasi` the same way. Consistency is enforced.


## Sidebar Scripts

All sidebars live in `~/.config/rofi/scripts/` and use the same pattern:

- Icon-only menu in a 100px-wide right panel
- Fat icons rendered in `feather` font (20px via `element-text`)
- Items are single icons with a trailing space: `"󰅴 "` (no leading space)
- Uses `shared/menu.rasi` with `-theme-str "listview { lines: N; }"`

| Script | Trigger | Icons | Description |
|--------|---------|-------|-------------|
| `wifi.sh` | `SUPER + A` | 󰀂 󰇚 󰤪/󰤨 󰋵 | Scan, saved, toggle, exit |
| `bluetooth.sh` | `SUPER + B` | 󰂯 󰂰 󰁪 󰋵 | Power, scan, devices, exit |
| `audio.sh` | `SUPER + SHIFT + A` | 󰋲 󰝚 | Recently played (album art), audio apps |
| `notes.sh` | `SUPER + SHIFT + N` | 󰅴 󰋼 󰋁 | New note, view notes, open folder |
| `search.sh` | `SUPER + SHIFT + F` | 󰈞 󰛳 󰏫 󰅶 | File, web, text, recent |
| `kb-layout.sh` | `SUPER + SHIFT + K` | 󰌌 | Keyboard layout toggle |
| `config-hud.sh` | `SUPER + SHIFT + I` | 󰐥 󰡟 󰏘  | Animations, visuals, layout, rounding |

Each sidebar opens centered `shared/list.rasi` dialogs for sub-actions (selecting networks, picking notes, etc.).



## Quick Config HUD

`scripts/config-hud.sh` is a live Hyprland settings panel that writes to `settings/overrides.lua` and reloads the compositor — no manual config file editing, no `hyprctl keyword`.

| Category | What It Toggles / Sets |
|----------|------------------------|
| 󰐥 **Animations** | On / Off |
| 󰡟 **Visuals** | Blur (on/off), Shadow (on/off), Dim (0.3 / 0.0) |
| 󰏘 **Layout** | Gaps In (0–8px), Gaps Out (0–16px), Border (1–4px) |
|  **Rounding** | Window rounding (0–20px) |

State is cached in `~/.cache/blacknode/hud-state` so changes persist across sessions.  The `overrides.lua` file is loaded at the end of `hyprland.lua` via `pcall(require, "settings/overrides")`.


## bn-menu Submenus

bn-menu (`~/.local/bin/bn-menu`) launches 15 submenus from `~/.local/bin/scripts/*/menu.sh`.  Each submenu shows 6–8 items with icon + text in a centered 380px window using `submenu.rasi`.

| Menu | Script | Items |
|------|--------|-------|
|  System | `system/menu.sh` | System settings |
| 󰓃 Audio | `audio/menu.sh` | Audio controls |
| 󰍹 Display | `display/menu.sh` | Display settings |
| 󰖰 Window | `window/menu.sh` | Window management |
| 󰹑 Screenshot | `screenshot/menu.sh` | Screenshot tools |
| 󰥰 Processes | `process/menu.sh` | Process management |
| 󰏗 Packages | `package/menu.sh` | Package management |
|  Applications | `apps/menu.sh` | App launcher |
| 󰸉 Wallpapers | `wallpaper/menu.sh` | Wallpaper selection |
| 󰄉 Waybar | `waybar/menu.sh` | Bar styles |
| 󰑐 Reload | `reload/menu.sh` | Config reload |
| 󱖫 Services | `services/menu.sh` | Service management |
| 󰌌 Theme | `theme/menu.sh` | Theme settings |
| 󰋼 About | `info/menu.sh` | Project info, stats, keybinds, README, dotfile browser |
| 󰍃 Session | `session/menu.sh` | Session control |
| 󰂯 Bluetooth | `bluetooth/menu.sh` | Bluetooth management |


## Development Rules

When adding new features to this system, follow these rules:

1. **Sidebars use `shared/menu.rasi`** with `-theme-str "listview { lines: N; }"`.  Do not create per-menu `.rasi` files.
2. **List menus use `shared/list.rasi`**.  No width/font/padding/lines overrides.
3. **Input dialogs use `shared/input-dialog.rasi`**.  No overrides.
4. **Icons in sidebar data strings** follow `"󰅴 "` — icon immediately followed by a single trailing space, no leading space.
5. **bn-menu items** use the same pattern: `"  System"` — icon, double space, text label.
6. **If something repeats more than once**, modularize it into `shared/`.
7. **No standalone themes**.  Every `.rasi` imports from `shared/` and `colors.rasi`.
8. **Hyprland runtime changes** go through `settings/overrides.lua` + `hyprctl reload`, never `hyprctl keyword` (Hyprland 0.55+ Lua).

**— HollowSec**
