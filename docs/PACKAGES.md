# Packages

## Core
- **Arch Linux** — distribution.
- **Hyprland 0.55+** — compositor with Lua configuration.
- **Kitty** — terminal emulator.

## Theme & Appearance
- **matugen** — generates Material You colour palettes from the wallpaper. Outputs to `~/.config/matugen/`.
- **powerlevel10k** — ZSH prompt. Loaded from `~/powerlevel10k/`. Configured via `~/.p10k.zsh`.

## Launchers & Menus
- **rofi** — launcher, bn-menu hub, sidebar menus, config HUD. All themes are modular under `~/.config/rofi/shared/`.
- **wlogout** — logout/power screen.

## Bar
- **waybar** — status bar with custom modules for updates, media, system resources.

## Notifications
- **dunst** — notification daemon.

## Clipboard
- **clipse** — clipboard manager.

## Utilities
- **fzf** — fuzzy finder, integrated with ZSH completions and history.
- **playerctl** — media player control (used by audio script).
- **brightnessctl** — screen brightness (used by multimedia keys).
- **wireplumber** — audio session management.
- **pavucontrol** — PulseAudio volume control GUI.
- **grim + slurp + hyprshot** — screenshots.
- **awww** — GPU-accelerated Wayland wallpaper daemon.
- **pacman-contrib** — provides `checkupdates` for Waybar update module.

## Development
- **node/npm** — JavaScript runtime.
- **pnpm** — package manager (aliases: `pdev`, `pbuild`, `pinstall`).
- **python** — Python 3.
- **firebase-tools** — Firebase deployment (`fd` alias).
- **yt-dlp** — video downloader.
- **git** — version control.

## Shell
- **ZSH** — default shell.
- **fzf-tab** — tab completion with fuzzy finder.
- **zsh-autosuggestions** — command suggestions from history.
- **zsh-syntax-highlighting** — real-time syntax colouring.
- **zsh-history-substring-search** — history search with arrow keys.
- **zsh-completions** — extra completion definitions.
- **zsh-you-should-use** — alias reminders.
- **exa** — modern `ls` replacement (aliases: `ls`, `la`, `ll`, `tree`).
- **bat** — `cat` with syntax highlighting.

## Network
- **networkmanager** — network management (Wi-Fi scripts use `nmcli`).
- **bluez + blueman** — Bluetooth management.

## Fonts
- **feather** — icon font for Rofi sidebars.
- **nerd-fonts** — icon fonts for Waybar, prompt, menus.
- **noto-fonts** — fallback CJK and emoji coverage.

## Installation Dependencies
For a fresh install, install all of the above via:
```bash
sudo pacman -S hyprland kitty rofi waybar dunst fzf playerctl brightnessctl wireplumber pavucontrol grim slurp awww pacman-contrib npm python git zsh exa bat networkmanager bluez blueman noto-fonts
yay -S matugen clipse wlogout hyprshot yt-dlp pnpm powerlevel10k
```
