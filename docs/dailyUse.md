# Daily use

The menu and the bar keep routine actions close to the keyboard. The design reasoning is in [philosophy.md](philosophy.md).

## The BlackNode menu

`SUPER + SPACE` opens `~/.config/rofi/scripts/launcher.sh`. It is an action menu, not an application launcher. The entries cover WiFi, Bluetooth, audio, bookmarks, keyboard layout, music, clipboard, shortcuts, pomodoro, screenshots, recording, wallpaper, emoji, What's New, reload, and session actions. Each entry calls a script in `rofi/scripts/`.

`SUPER + R` opens `rofi -show drun`, which is the application launcher. The BlackNode menu is the control panel; `drun` searches `.desktop` files.

The Rofi theme is `themes/presets/submenu.rasi`, which imports the generated `colors.rasi`. `config.rasi` sets `@theme "~/BlackNode/Configs/.config/rofi/themes/presets/submenu.rasi"`, so the repo must be at `~/BlackNode`. The scripts use `$HOME/.config/rofi/...`, which works because the installer links the directory.

## Waybar

The bar is assembled with includes:

`waybar/config.jsonc` -> `Layouts/blacknode.jsonc` -> `Modules/modules.jsonc` -> `Modules/*.jsonc`.

`config.jsonc` sets position, height, margins, and `reload_style_on_change`. The module list and visual order are in `Layouts/blacknode.jsonc`. Each `hollow-*` group collects modules and is styled in `style.css`.

The left groups hold the distro, workspaces, privacy and volume, and package updates. The center groups hold the idle inhibitor and clock. The right groups hold network, Bluetooth, backlight, battery, MPRIS, weather, and logout.

Script-backed modules include `custom/weather` (`~/.config/waybar/Scripts/weather/script.py`), `custom/osDistro` (`userDistro.sh`), the package update scripts, `custom/notDisturb`, and the privacy modules. `wireplumber`, `mpris`, and `idle_inhibitor` are native.

`packagePacman.jsonc` uses `exec-if` with `checkupdates`. Without `pacman-contrib`, the module does not appear. The MPRIS player icons use fixed Catppuccin colors, so they do not follow `matugen`.

The Waybar layout picker scripts rewrite `config.jsonc` with the chosen layout. There is only one layout file (`blacknode.jsonc`), so the picker has one useful entry. The launcher version points at `rofi/styles/submenu.rasi`, which does not exist; `WaybarLayout.sh` uses the correct `themes/presets/submenu.rasi`.

## Notifications and OSD

Dunst receives `notify-send` messages. `dunstctl` controls Do Not Disturb; `notDisturb.sh` toggles it and Waybar shows the state.

The OSDs are notifications with an icon. `audio.sh`, `brightness.sh`, `devices.sh`, and `media.sh` write to `/tmp/blacknode-icons` and call `notify-send`. `media.sh` downloads cover art to `/tmp/blacknode-music-cover`; if there is no network or no player, it shows the title without a cover. The OSD scripts are separate from the Waybar modules.

`service-failed.sh` watches `dbus-monitor` and reports failed user units. The battery scripts keep state files in `/tmp` so they do not repeat the same warning. `wifi.sh` and `bluetooth.sh` also watch events and send notifications.

## Weather and news

There are three weather paths, and they do not share a source:

| Path | Source | Location |
|---|---|---|
| Waybar | `ip-api.com`, `open-meteo.com` | detected by IP, cached for 900 s |
| Lock screen | `open-meteo.com` | fixed to `13.67, -89.28` in `hypr/scripts/weather.sh` |
| Notification | `ip-api.com`, `open-meteo.com` | `system/weather/script.sh`, cached in `/tmp` |

News has its own split. `whatsnews.sh` fetches `https://raw.githubusercontent.com/zhaleff/BlackNode/main/whatnews.json`, shows unseen entries with `notify-send`, and stores seen IDs in `~/.local/share/blacknode/whatsnew_seen`. The local `whatnews.json` must be pushed to GitHub before the notification sees it. The Rofi entry `whatnews.sh` only opens the repository in a browser; it does not read the local file.

## Clipboard

There are two clipboard paths:

- `clipse` stores history in `Configs/.config/clipse/clipboard_history.json` and uses `themeFile: blacknode.json`.
- `rofi/scripts/clipboard.sh` uses `cliphist` and `wl-copy`, with pinned items in `~/.local/share/cliphist/pins`.

`autostart.lua` starts the `wl-paste` watchers that feed `cliphist`, so the Rofi path has data. Clipse is not started by autostart. Its `config.json` points at `blacknode.json`, but no template generates that file; the tracked file is `custom_theme.json`. If you open Clipse, expect the default theme or a missing theme file.

## Shell

`.zshrc` sources the modules in this order: `theme`, `plugins`, `keybinds`, `options`, `completion`, `env`, `aliases`, `functions`.

A few details matter:

- `theme.zsh` sources `~/powerlevel10k/powerlevel10k.zsh-theme` and `~/.p10k.zsh`. The repo contains `Configs/.config/powerlevel10k/`, but the installer does not link it to `~/powerlevel10k`. Without a manual clone or link, the prompt does not load.
- `plugins.zsh` sources plugin files from `/usr/share/zsh/plugins/...`. Those packages are not in `packages.json`. If a path is missing, `_plug` prints an error and continues.
- `plugins.zsh` sets `HISTFILE` under `$XDG_STATE_HOME`, then `options.zsh` sets it to `~/.zsh_history`. The later assignment wins.
- Aliases use `exa`, and the fzf previews use `eza`. Neither is in `packages.json`.
- The vendored `Configs/.config/zsh/plugins/fzf-zsh-plugin/` and `zsh-fzf-history-search/` are in the repo but not sourced by `.zshrc`.

## Editor and files

Neovim uses `lazy.nvim`, which clones itself on first start. The plugin set is in `Configs/.config/nvim/lua/core/plugins/`, with LSP configuration in `core/lsp/`. `matugen` writes `core/highlights/colors.lua`, and `core/highlights/core.lua` requires it, so the generated palette is active as long as that file exists.

Yazi uses Catppuccin Mocha in `theme.toml` and `init.lua`, plus the `git`, `full-border`, `chmod`, and `yatline-githead` packages. The yatline status line is commented out in `init.lua`. The palette is duplicated in two files, so a change needs both edits. Yazi does not read the `matugen` output.

Fastfetch uses `~/.config/fastfetch/assets/current.png` as its logo. `fastfetch.sh` picks a random image, updates the symlink, and runs `/usr/bin/fastfetch`. The logo type is `kitty-direct`, so the image only appears in Kitty.

Kitty includes `colors.conf`, uses JetBrainsMono Nerd Font, hides window decorations, and disables the audio bell. It is the terminal the rest of the setup assumes.
