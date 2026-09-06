# Listeners

Independent Bash processes launched at login from `autostart.lua`. Each monitors one event source. No shared state. No dependencies between them.

---

## Battery — `system/battery/`

Three scripts, each handling one aspect:

- **battery-full.sh** — Polls `/sys/class/power_supply/BAT0` every 30s while charging. Notifies at thresholds 80/90/95/100%. Uses a state file in `/tmp/` to avoid repeating notifications. Resets state when charger is disconnected.

- **battery-low.sh** — Same pattern while discharging. Thresholds at 20/15/10/5%. Escalates urgency to critical at 10% and below.

- **battery-plug.sh** — Detects charger connect/disconnect transitions via a boolean flag. Notifies once per transition with current capacity.

**Why polling:** `/sys/class/power_supply` is a static kernel filesystem. No file watcher exists. 30-second polling is the industry standard (GNOME, KDE, Sway all do the same).

---

## Bluetooth — `system/bluetooth/bluetooth.sh`

Runs `bluetoothctl` in foreground and pipes its output through a `while read` loop that pattern-matches `[CHG]` events in real time. Detects: powered on/off, discovering, device connected/disconnected. Resolves device names and battery percentages via `bluetoothctl info`.

Stores known device names in an associative array so it can display the name on disconnect (when `bluetoothctl info` may no longer report it).

No polling. The kernel emits D-Bus events on every state change. `bluetoothctl` streams them. The `while read` consumes them line by line with sub-second latency.

---

## WiFi — `system/network/wifi.sh`

Same pattern as bluetooth but over `nmcli monitor`. Detects: connected (with SSID), disconnected, no network. Forces `LC_ALL=C` to guarantee English output regardless of system locale (otherwise pattern matching breaks on localized strings).

No polling. NetworkManager emits D-Bus events in real time.

---

## OSD — `system/osd/`

These are **on-demand scripts**, not persistent listeners. Triggered by XF86 hardware keys via Hyprland keybinds.

- **audio.sh** — After `wpctl` changes volume, reads the result and sends a notification with icon selected by range (off/min/cross/loud/muted). Uses dunst's synchronous hint to replace the previous notification instead of stacking.

- **brightness.sh** — After `brightnessctl` changes brightness, reads the percentage and sends a notification with a progress bar.

- **media.sh** — The one exception: runs as a persistent listener via `playerctl --follow metadata`. Detects track changes and sends notifications with album art downloaded from `mpris:artUrl`.

- **devices.sh** — Listens on `udevadm monitor --subsystem-match=usb`. Filters sub-interfaces (paths containing `:`) to notify only once per physical device, not per USB interface. Resolves device names via `udevadm info`.

---

## Package — `system/package.sh`

Runs once at login. Checks `checkupdates` for pending pacman updates. Sends a single notification if count > 0, then exits. No loop, no watch.

---

## Weather — `system/weather/script.sh`

Runs once at login. Geolocates via ip-api.com (cached in `/tmp/`). Fetches current conditions from Open-Meteo (free, no API key). Sends temperature notification. Only warns about rain if probability >= 70% (high threshold to avoid false positives).
