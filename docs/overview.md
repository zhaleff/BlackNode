# Visión general

BlackNode es un sistema de dotfiles para Hyprland (Arch Linux). Diseñado alrededor de una premisa: cada componente hace una sola cosa, sin abstracciones innecesarias, sin dependencias entre procesos.

## Arquitectura

```
┌──────────────────────────────────────────────────────────────────┐
│                     Hyprland (compositor)                         │
├──────────┬───────────────────┬──────────────────┬────────────────┤
│  Waybar  │   Rofi (menus)    │   Dunst (notify) │  matugen       │
│  bar     │   launcher.sh     │   dunstctl       │  (theme engine)│
├──────────┴───────────────────┴──────────────────┴────────────────┤
│               .local/bin/system/  (listeners)                     │
│  battery · bluetooth · wifi · osd · media · devices · weather    │
├─────────────────────────────────────────────────────────────────-┤
│               .local/bin/blacknode/  (utilities)                  │
│  recolor-icons.sh · whatsnews.sh                                  │
└─────────────────────────────────────────────────────────────────-┘
```

Los listeners son procesos Bash que se lanzan una vez al inicio de sesión desde `autostart.lua`. Cada uno monitorea una fuente de eventos y envía notificaciones via `notify-send`. No hay orquestador central. Si uno muere, el resto sigue funcionando.

## Flujo de datos: cambio de wallpaper

```
wallpaper change → matugen image <wallpaper>
    │
    ├──→ colors.css (waybar)     ──▶ waybar live-reload
    ├──→ colors.rasi (rofi)      ──▶ rofi lee al abrir
    ├──→ colors.lua (hypr)       ──▶ hyprland reload
    ├──→ dunstrc                 ──▶ dunst restart
    ├──→ kitty/colors.conf       ──▶ kitty SIGUSR1
    ├──→ icons.json              ──▶ recolor-icons.sh (post_hook)
    │         └──→ /tmp/blacknode-icons/ (SVGs coloreados)
    │                   └──→ scripts de notificación leen desde /tmp
    └──→ nvim/generated.lua      ──▶ nvim SIGUSR1
```

## Estructura de directorios

```
BlackNode/
├── Configs/
│   ├── .config/
│   │   ├── hypr/             → [hyprland.md](hyprland.md)
│   │   ├── waybar/           → [waybar.md](waybar.md)
│   │   ├── rofi/             → [rofi.md](rofi.md)
│   │   ├── matugen/config.toml
│   │   └── ... (kitty, dunst, cava, nvim, btop, clipse, wlogout, sddm)
│   └── .local/
│       ├── bin/
│       │   ├── blacknode/recolor-icons.sh, whatsnews.sh
│       │   └── system/       → [listeners.md](listeners.md)
│       └── share/blacknode/
├── Scripts/ (install.sh, health.sh, linkdots.sh, failed.sh, lib/)
├── version.json, whatnews.json, weather-messages.json
└── docs/
```
