# Rofi

Menus grouped by domain. `launcher.sh` and `themes/` sit at the root. Every
script depends on them and they change rarely.

```
rofi/
├── config.rasi
├── colors.rasi
├── themes/presets/          # stable: visual contract
└── scripts/
    ├── launcher.sh          # stable: hub and "Back" navigation
    ├── appearance/          # wallpaper, wallselect
    ├── audio/               # audio, musicPlayer
    ├── bluetooth/           # bluetooth
    ├── display/             # monitor
    ├── keyboard/            # kb-layout, shortcuts
    ├── network/             # wifi
    ├── pomodoro/            # pomodoro
    ├── recording/           # recordscreen, screenshots
    ├── system/              # notification, package, powermenu, reload, whatnews
    └── utilities/           # bookmarks, clipboard, emoji
```

## Volatility

| Level | What | Rule |
| --- | --- | --- |
| Low | `launcher.sh`, `themes/`, one file per domain under `scripts/*/` | Paths stay fixed; keybinds and "Back" point here |
| Medium | `system/`, `keyboard/`, `appearance/` | Change with desktop configuration |
| High | `audio/`, `utilities/`, `launcher.sh` menu entries | Edited often; keep shared logic out |

`launcher.sh` is the most volatile file. Adding or removing an entry must not
force edits in other scripts, so each entry delegates to a domain script and
every script returns to the same launcher.

## Conventions

- `ROFI_DIR="$HOME/.config/rofi"` and themes always come from `themes/presets/`.
- Internal paths use `$ROFI_DIR/scripts/<domain>/<script>.sh`.
- Hyprland keybinds use the same absolute paths. Moving a script means updating
  `settings/keybinds.lua` and `waybar/Modules/*.jsonc`.
- Create a domain only when it has at least one stable script.
