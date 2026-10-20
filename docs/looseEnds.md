# Loose ends

This page lists the gaps that change how the setup behaves, plus the places where the repo and the running system disagree.

## Things that fail on a clean clone

| Symptom | Cause | Check or fix |
|---|---|---|
| Hyprland starts with missing colors or fails | `hypr/themes/colors.lua` is generated and ignored by git | Run `matugen` once or pick a wallpaper with `SUPER + W` |
| Waybar has no background or accent | `waybar/colors.css` is missing | Generate the theme, then `killall waybar && waybar &` |
| Kitty shows default colors | `kitty/colors.conf` is missing | Generate the theme, then `pkill -USR1 kitty` |
| Hyprlock has no background | `hyprlock.png` is copied by `wallselect.sh` and ignored by git | Pick a wallpaper, or copy an image to `~/.config/hypr/hyprlock.png` |
| Dunst fails to start | `dunstrc` is generated and ignored by git | Generate the theme, then restart Dunst |
| Clipse does not use the BlackNode colors | `config.json` points at `blacknode.json`, which no template generates | Create the file or change `themeFile` to `custom_theme.json` |
| The prompt looks plain | `theme.zsh` loads `~/powerlevel10k`, not the copy in the repo | Link or clone Powerlevel10k to `~/powerlevel10k` |
| The installer reads empty package lists or fails | `json.sh` uses `jq`, which is not in `packages.json` | Install `jq` before running the installer |
| Weather in Waybar shows `err` | `script.py` imports `requests`, which is not in `packages.json` | Install `python-requests` |
| Screenshots fail | `screenshots.sh` needs `grim`, `slurp`, `satty`, `wl-copy`, `hyprctl`, and `jq` | Install what is missing |
| `SUPER + SHIFT + R` does nothing | The bind points at `rofi/wf-recorder.sh`, which does not exist | Use `SUPER + G` (`recordscreen.sh`) or add the missing script |
| `SUPER + E` or `SUPER + Y` does nothing | `dolphin` and `spotify` are not installed by the installer | Install them or change the binds |

## Paths that do not line up

| Feature | What one file expects | What another file provides |
|---|---|---|
| Profiles | `wallselect.sh` reads `~/.local/share/blacknode/profiles/<active>/walls` | The installer creates `~/.config/hypr/profiles`; nothing writes the active profile |
| Theme mode | `wallselect.sh` reads `theme_mode` on the next run | `wallpaper.sh` writes it but does not apply it |
| News | `whatsnews.sh` fetches `whatnews.json` from GitHub `main` | The local `whatnews.json` is not read until it is pushed |
| Lock weather | `hypr/scripts/weather.sh` uses fixed coordinates | Waybar uses IP geolocation |
| Clipboard | Clipse expects `blacknode.json` | The tracked file is `custom_theme.json` |

## Rofi shortcuts are stale

`rofi/scripts/shortcuts.sh` lists an older keymap. It says `SUPER + H` for screenshots, `SUPER + SHIFT + H` for the recorder, `SUPER + L` for lock, and `SUPER + K` for music. The active binds are `SUPER + SHIFT + S` for screenshots, `SUPER + G` for recording, `SUPER + ESCAPE` for lock, and `SUPER + M` for music. The menu is a reference card; `settings/keybinds.lua` is the source.

## Installer quirks

- `--nvidia` appears in the help text but no code reads it. The GPU check decides.
- The installer uses `jq` to read `packages.json` but does not install `jq`.
- `Scripts/linkdots.sh` does not exist. Symlinking is the `link_configs` step of `Scripts/install.sh`.

## Shell details

- `theme.zsh` loads Powerlevel10k from `~/powerlevel10k`, outside the repo.
- `plugins.zsh` sets `HISTFILE` under `$XDG_STATE_HOME`; `options.zsh` sets it to `~/.zsh_history` later, so the XDG path does not win.
- `plugins.zsh` and `completion.zsh` both run `compinit`.
- The vendored `fzf-zsh-plugin` and `zsh-fzf-history-search` directories are not sourced by `.zshrc`.

## What to check before filing a bug

Run these from a terminal inside the session:

```bash
hyprctl version
hyprctl monitors
hyprctl clients
pgrep -a waybar
pgrep -a dunst
ls -l ~/.config/hypr/themes/colors.lua ~/.config/waybar/colors.css
tail -n 50 ~/.blacknode-install.log
journalctl --user -b --no-pager | tail -n 80
```

If the problem is visual, run the script that should have changed the screen by hand and read the error. Most of the gaps above are missing binaries or missing generated files, and both show up immediately in a terminal.
