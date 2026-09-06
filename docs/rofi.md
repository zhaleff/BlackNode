# Rofi Menus

## The Hub: launcher.sh

`SUPER+SPACE` opens the main BlackNode menu. It's a flat list of 17 options, each dispatching to a dedicated submenu script. No nested menus deeper than one level.

Options: WiFi, Bluetooth, Audio, Bookmarks, Keyboard Layout, Music, Clipboard, Shortcuts, Pomodoro, Screenshots, Record Screen, Wallpaper, Kill Process, Emoji Picker, Reload, Whats New, Session.

Every submenu has a "Back" option at the top that re-launches `launcher.sh`, creating a simple hub-and-spoke navigation pattern.

## Submenu Behavior

Each submenu script follows the same pattern: present choices via rofi, process selection via case statement, execute the action, then re-launch itself (for recursive navigation) or re-launch `launcher.sh` (to go back).

**WiFi** — Scans networks via nmcli, shows signal-strength icons (5 levels) and security indicators. Connects to saved networks directly or prompts for password via rofi for new ones. Toggle WiFi on/off.

**Bluetooth** — Lists paired devices, connect/disconnect via D-Bus (`busctl call org.bluez`), toggle power.

**Audio** — Volume mute, +/-10%, per-app volume control (lists active sink-inputs from pactl, allows individual app muting), microphone mute.

**Clipboard** — Uses cliphist. Browse history, pin items (persisted to `~/.local/share/cliphist/pins/`), view pinned items, wipe history.

**Kill Process** — Lists open windows via `hyprctl clients -j`, sends SIGTERM with fallback to SIGKILL after 1 second.

**Wallpaper** — Reads active profile for wallpaper directory, shows image previews in a 4-column grid, applies via awww (wallpaper daemon), copies to hyprlock.png, runs matugen for full theme regeneration, restarts waybar/dunst/cava/kitty/firefox.

**Reload** — Independent options: restart Waybar, reload Hyprland, restart Dunst, or reload everything. Each uses kill + 0.3s sleep + relaunch to avoid race conditions.

**Pomodoro** — Wrapper around pomodoro-cli: Work (25m), Study (45m), Short Break (5m), Long Break (15m), custom time, pause/resume, stop.

**Bookmarks** — Hardcoded array of 17 sites (YouTube, GitHub, Instagram, WhatsApp, LinkedIn, Reddit, Gmail, Discord, Amazon, StackOverflow, Claude, ChatGPT, Telegram, Spotify, Firefox, Google, X). Opens via xdg-open. No config file — edit the script to change.

**Power Menu** — Lock, Suspend, Hibernate, Logout, Reboot, Shutdown. All destructive actions require rofi confirmation dialog.

**Screenshots** — Region, window (via hyprctl geometry), output, or all screens. Uses grim + slurp + satty for annotation. Copies to clipboard.

**Record Screen** — Fullscreen or region selection via slurp, with/without audio. Stop via pkill. Outputs to ~/Videos/Recordings.

## Themes

Two rofi themes, both Material Design 3 with matugen colors:

- **submenu.rasi** — Centered 520x520 popup. 6 visible lines. Used by most submenus.
- **submenu-wide.rasi** — Bottom-anchored 680x520. 11 visible lines. Papirus-Dark icons. Used as the default for the main app launcher (`config.rasi`).
- **wallselect.rasi** — Full-width bottom carousel, 4-column grid, 300px thumbnail icons.

Font is JetBrainsMono Nerd Font throughout. Selection uses pill-shaped highlight (999px border-radius) with `@primary` background.
