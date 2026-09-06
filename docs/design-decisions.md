# Design Decisions

## Why Bash, Not Python

The notification layer that was removed in September 2026 was a Python system: engine, registry, service, plugins, sensors, "psyche" with personality/timing/framing. It was overengineered for what was actually needed: read a value, compare a threshold, send a notification.

Bash is the right tool here because:
- Every listener is 10-60 lines. No data structures, no HTTP, no complex parsing.
- Bash is part of the base Arch system. Python plus `requests` is an extra install step.
- Startup time is instant for Bash. Python has import/compile overhead.
- The one exception is `waybar/Scripts/weather/script.py` — geolocation, reverse geocoding, cache management, 28 WMO weather codes, HTML tooltips. That's 260 lines where Python is the correct choice.

## One Process Per Event Source

Bluetooth gets one `bluetoothctl` process. WiFi gets one `nmcli monitor`. USB gets one `udevadm monitor`. No replication.

Duplicating listeners wastes memory and CPU for zero benefit. Worse, multiple processes sending the same notification causes visual glitches in dunst (stacking, flickering). One producer per event eliminates this.

## No Central Orchestrator

The old system had an orchestrator that coordinated plugins and sensors. It was a single point of failure, added configuration complexity, and created inter-dependencies between components that should be independent.

Now: bluetooth.sh doesn't know wifi.sh exists. battery.sh doesn't care about the rofi menu. Each listener is fully autonomous. If one crashes, the rest continue unaffected.

## Polling Only Where Necessary

- **Battery:** `/sys/class/power_supply` is a static kernel filesystem. No file watcher. 30-second polling is the only option. This matches GNOME and KDE.
- **Bluetooth, WiFi, USB:** The kernel emits D-Bus/udev events in real time. No polling needed. `bluetoothctl`, `nmcli monitor`, and `udevadm monitor` provide streaming output consumed by `while read` loops.
- **Audio/Brightness OSD:** No listeners at all. Hyprland executes the change (`wpctl`/`brightnessctl`) and then runs the script to read the result. The script is a one-shot, not a daemon.

## Why No Tor/VPN/DNS in the Menu

The criterion for inclusion in `launcher.sh`: does the user do this multiple times a day?

WiFi, Bluetooth, Audio, Screenshots, Clipboard — yes, repeated many times daily. Tor, VPN, DNS — configured once and forgotten. Adding them to the main menu adds visual clutter without reducing friction. A dedicated keybind or script handles them fine.

## Why Hardcoded Bookmarks

The bookmark array is a Bash associative array in the script. No config file, no JSON, no YAML.

For 17 URLs that change once a year at most, a config file means: a parser, a format to maintain, validation code, error handling. The Bash array is the most direct representation of the data. Zero parsing overhead, zero dependencies.

## Why /tmp for Icon Cache and State

Icons in `/tmp/blacknode-icons/` and battery state in `/tmp/blacknode-battery-*-state` are recreated automatically. Icons rebuild on every theme change. Battery state resets on charger plug/unplug.

Advantage: clean slate on reboot. No stale cache files, no state corruption bugs. Risk: if the theme changes mid-charge-cycle, a threshold notification might be missed. Acceptable — the next cycle catches it.

## Waybar Module Design

The bar uses a three-level include system (config → layout → modules) to separate concerns. 31 individual `.jsonc` module files mean surgical edits: change one module without touching the layout or other modules.

Custom modules use waybar's `exec` + `return-type: json` to run scripts and parse their output. The `class` field in JSON output drives CSS-based conditional styling (red for privacy active, green/yellow/red for pomodoro states, warning blink for low battery).

The pomodoro module is the only one using waybar's `signal` mechanism — `pomodoro-cli` sends `SIGRTMIN+10` to force immediate UI updates on user actions instead of waiting for the next polling interval.

## Hyprland Lua Config

Hyprland v0.55+ supports Lua configuration with `require()`. Each settings area is a separate Lua file. The entry point `hyprland.lua` requires them all and loads the active profile last.

Profiles override settings per context (study, coding, default). The active profile is read from a simple text file (`profiles/.active`). Optional overrides are loaded via `pcall` so a broken override file doesn't break the entire config.
