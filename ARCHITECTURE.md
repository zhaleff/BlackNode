# BlackNode Architecture

Hyprland dotfiles. September 2026 refactor: killed the entire Python notification layer (engine, registry, service, plugins, sensors, "psyche" with personality/timing/framing), replaced with independent Bash scripts in `.local/bin/system/`.

One process per event source. No central orchestrator. No shared state between listeners. Each script does exactly one thing.

| Doc | Topic |
|-----|-------|
| [overview.md](docs/overview.md) | System architecture and directory layout |
| [listeners.md](docs/listeners.md) | System state listeners |
| [icons-theming.md](docs/icons-theming.md) | Icon pipeline and matugen theming |
| [waybar.md](docs/waybar.md) | Status bar modules and layout |
| [rofi.md](docs/rofi.md) | Main menu and submenus |
| [hyprland.md](docs/hyprland.md) | Compositor config and autostart |
| [design-decisions.md](docs/design-decisions.md) | Why things are the way they are |
