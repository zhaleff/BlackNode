# Icons and Theming

BlackNode uses matugen as the single source of truth for color. One wallpaper drives a Material Design 3 palette that recolors the entire desktop.

## The Pipeline

When the user picks a wallpaper (via rofi), matugen runs against that image. It generates color tokens for 17 targets: waybar, rofi, dunst, kitty, hyprland, nvim, cava, btop, clipse, wlogout, hyprlock, and VS Code. Each target has a template file that matugen fills with the extracted palette.

The critical post-hook is `recolor-icons.sh`. It reads the `on_surface` color from matugen's `icons.json` output and substitutes it into every SVG source file (Lucide-style icons with `stroke="{{fill}}"` and `fill="none"`). The colored copies go to `/tmp/blacknode-icons/`, preserving the subdirectory structure.

## Why /tmp

The icon cache lives in `/tmp/` deliberately. On reboot it's gone, and `recolor-icons.sh` rebuilds it on the next theme change. This means no stale state, no cache invalidation bugs, no disk space accumulation. Every script that needs an icon reads from `/tmp/blacknode-icons/` and trusts that it's current.

## Separation of Concerns

No notification script resolves colors on its own. They all reference pre-colored SVGs from `/tmp/blacknode-icons/`. The color is resolved once per theme change (when matugen runs), and every consumer reads the already-resolved result. This means adding a new notification type only requires adding the SVG source to the source tree — no script changes needed.

## Template Count

The 17 matugen templates cover every visible surface:

- **Compositor:** hyprland colors, hyprlang variables, hyprlock config
- **Bar:** waybar CSS tokens
- **Menus:** rofi color tokens
- **Notifications:** dunst config
- **Terminal:** kitty colors
- **Editor:** neovim generated palette (with SIGUSR1 reload)
- **Apps:** cava, btop, clipse, wlogout themes
- **IDE:** VS Code color scheme (raw + JSON)
- **Icons:** the recolor pipeline described above
