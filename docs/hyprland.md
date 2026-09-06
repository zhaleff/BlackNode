# Hyprland Configuration

## Modular Structure

`hyprland.lua` is the entry point. It uses Hyprland's Lua `require()` system (v0.55+) to load each settings module independently: keybinds, device, monitor, gesture, master-layout, scrolling-layout, misc, dwindle, autostart, input, general, decoration, animations, themes/colors, rules, env.

Optional overrides are loaded via `pcall(require, "settings/overrides")` — if the file doesn't exist or has errors, the rest of the config still works.

The active profile is loaded last by reading `profiles/.active` and requiring the matching Lua file. Profiles can override any setting: different gaps, colors, keybinds, or workspaces per context.

## Autostart

`autostart.lua` launches everything on `hyprland.start`. Direct execution, no wrapper script, no orchestrator:

**Services:** nm-applet (NetworkManager tray), waybar, hypridle (idle manager), awww-daemon (wallpaper), dunst (notifications), cliphist (clipboard history), cursor theme.

**One-shot notifications:** package.sh (update count), whatsnews.sh (changelog).

**OSD scripts:** audio.sh, brightness.sh, media.sh — launched for availability, though they're primarily triggered by keybinds.

**Persistent listeners:** battery-low.sh, battery-full.sh, battery-plug.sh, devices.sh, wifi.sh, bluetooth.sh — one process each, running indefinitely.

Each launch is independent. If one fails to start, nothing else is affected.

## Keybinds

`keybinds.lua` defines all keybinds. Key patterns:

- **XF86 hardware keys** — volume/brightness use `&&` to chain the actual change (`wpctl`/`brightnessctl`) with the OSD notification script. `locked = true` works even with the screen locked. `repeating = true` allows held-key repeat.
- **Media keys** — playerctl next/previous/play-pause, also `locked`.
- **App launchers** — SUPER+B (Firefox), SUPER+D (Kitty), SUPER+E (Dolphin), SUPER+Y (Spotify).
- **Menu keys** — SUPER+SPACE (BlackNode launcher), SUPER+R (rofi drun), SUPER+T (music player), SUPER+SHIFT+X (power menu).
- **Utility keys** — SUPER+H (screenshots), SUPER+W (wallpaper), SUPER+V (clipboard), SUPER+L (lock), SUPER+Q (close window).
- **Workspaces** — SUPER+1-9 to focus, SUPER+SHIFT+1-9 to move. Mouse scroll for workspace switching.

## Profiles

Profiles live under `profiles/` with a `.active` file selecting the current one. A profile can override any Hyprland setting. The default profile has no overrides. Profiles for "study" or "coding" contexts can change layouts, gaps, or available apps.

When a profile is active, the waybar launcher (`script.sh`) and layout selector (`layout.sh`) detect it and open the profile's dedicated command center instead of the generic layout picker.

## Decoration and Animations

Decoration uses Hyprland v0.40+ style: rounding=10, inactive opacity=0.8, blur with size=6 and 3 passes.

Animations are defined in `animations/vertical.lua` with custom easing curves: standard, emphasized, smoothOut, windowBounce, layerBounce, workspaceBounce, linear. Window animations use slidevert style with bounce easing — windows slide in vertically with overshoot.

Runtime overrides in `overrides.lua` adjust rounding to 16, gaps_in to 3, gaps_out to 7 at runtime, creating a tighter feel than the base config.

## Rules

20+ window rules define app-specific behavior: clipse and imv get specific sizing, kitty gets blur on its background, firefox and spotify get specific workspace assignments, various apps get no anim/no blur/no shadow treatments. Layer rules add blur for kitty/waybar/rofi/alacritty backgrounds and disable animations for selection/hyprpicker overlays.
