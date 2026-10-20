# Design principles

BlackNode is a dark Hyprland desktop for Arch Linux. The background is near-black and the accent colors come from the wallpaper.

## The palette follows the wall

`matugen` extracts Material You roles from the image (`primary`, `surface`, `on_surface`, `error`) and writes them in the format each program needs. There is no theme picker; change the wallpaper and the palette changes with it.

Some programs keep their own palette. Yazi uses Catppuccin Mocha, Fastfetch uses blue, and Clipse has a gold theme. [aesthetics.md](aesthetics.md) explains which ones can join the pipeline and which ones are better left alone.

## The keyboard is the primary interface

`SUPER` is the main modifier. The same four keys (`h`, `j`, `k`, `l`) focus, move, resize, and drag depending on the other modifier. Workspaces run from 1 to 9, the brackets move between them, and `TAB` returns to the last one. The mouse works, but it is the slower path.

The logic is the one from a modal editor. Learn a small grammar and repeat it. If a frequent action needs a menu, the binding is not finished.

## The session closes

Idle behavior is a fixed sequence. At 5 minutes the brightness drops, at 7 it locks, at 8 the display turns off, and at 15 it suspends. The timers are in `~/.config/hypr/hypridle.conf`. The desktop is built for work, not for staying awake.

## Files you can read

Configuration is text files linked from the repo into the home directory. There is no central daemon. Open `~/.config/hypr/settings/keybinds.lua` and change a key. Open `~/.config/waybar/Modules/weather.jsonc` and change the interval. This manual uses the same file names and paths as the files.

A file belongs in the repo if you can explain what it does in one paragraph and what breaks it. If you cannot, it is not finished.

## Limits

BlackNode assumes Arch Linux, Hyprland, a single-user Wayland session, and a `us,es` keyboard. It is not hardened and does not promise to work on another distro. The repo is meant to be edited, not installed and forgotten.

If you add something, ask three questions. Does it remove a step or only add an option? Does it survive a clean clone with no generated files? Can you explain it without a diagram? All three answers should be yes.
