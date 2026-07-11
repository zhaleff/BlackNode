# Waybar Modules

All modules are grouped logically on the bar. The Classic style uses the following layout.

## Left Side

### Workspaces
- **Module:** `hyprland/workspaces`
- Shows all workspaces. Active workspace uses icon `󰮯`, others use `*`.
- `all-outputs: true` — shows workspaces from all monitors.
- `persistent_workspaces` — guarantees at least three visible.

### Media Controls
- **Modules:** `mpris`, `custom/previous`, `custom/pause`, `custom/next`
- `mpris` — displays now-playing (title + artist) with per-player icons (Spotify, Firefox).
- `custom/pause` — toggles play/pause. Icon: `` (play), `` (pause).

### System Tray & Hardware
- **Modules:** `backlight`, `wireplumber`, `network`, `custom/power`, `battery`
- `backlight` — brightness level, icon changes with level.
- `wireplumber` — volume with mute indication.
- `network` — Wi-Fi strength or Ethernet IP. Click opens Wi-Fi Rofi script.
- `custom/power` — launches wlogout on click.
- `battery` — percentage and charging status.

### Package Updates
- **Modules:** `custom/pacman`, `custom/pkg-aur`
- `custom/pacman` — count of official updates (from `checkupdates`). Click opens `sudo pacman -Syu`.
- `custom/pkg-aur` — AUR update count (from `yay -Qua`). Informational only.

## Right Side

### Active Window
- **Module:** `hyprland/window`
- Shows window title, truncated to 32 chars. Prefixed with `󰶞`.
- `separate-outputs: false` — shows current output's window.

### Idle Inhibitor & Clock
- **Modules:** `idle_inhibitor`, `clock`
- `idle_inhibitor` — toggles idle/suspend. Icon: `󰛊` (inactive), `󰅶` (active).
- `clock` — shows time in `HH:MM`. Hover shows full calendar.

### System Resources
- **Modules:** `cpu`, `temperature`, `memory`
- `cpu` — usage percentage, prefixed with ``. Click opens `btop`.
- `temperature` — CPU temperature (thermal zone 2). Icon ``. Threshold 80°C.
- `memory` — RAM usage percentage, prefixed with ``.

### User Info
- **Module:** `custom/user`
- Shows `whoami` output, prefixed with ``. Click sends notification with `whoami@hostname`.

## Full Module Reference

| Module | Group | Purpose |
|--------|-------|---------|
| `hyprland/workspaces` | left | Workspace switcher |
| `mpris` | left | Now playing |
| `custom/previous` | left | Previous track |
| `custom/pause` | left | Play/pause |
| `custom/next` | left | Next track |
| `backlight` | left | Screen brightness |
| `wireplumber` | left | Audio volume |
| `network` | left | Network status |
| `custom/power` | left | Power menu |
| `battery` | left | Battery status |
| `custom/pacman` | left | Package updates |
| `custom/pkg-aur` | left | AUR updates |
| `hyprland/window` | right | Active window |
| `idle_inhibitor` | right | Idle toggle |
| `clock` | right | Time/date |
| `cpu` | right | CPU usage |
| `temperature` | right | CPU temperature |
| `memory` | right | RAM usage |
| `custom/user` | right | Username display |
