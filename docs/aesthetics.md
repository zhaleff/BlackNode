# Color, shape, and noise

## One source, many outputs

The theme starts with an image. `wallselect.sh` applies the image with `awww`, copies it to `~/.config/hypr/hyprlock.png`, and runs:

```bash
matugen image "$SELECTED" -m "$THEME_MODE" --source-color-index 0
```

`matugen` reads `Configs/.config/matugen/config.toml`, processes each template, and writes the output file:

| Template | Output |
|---|---|
| `hyprlang.conf` | `hypr/themes/hyprlang.conf` |
| `hyprland.lua` | `hypr/themes/colors.lua` |
| `kitty.conf` | `kitty/colors.conf` |
| `waybar.css` | `waybar/colors.css` |
| `rofi.rasi` | `rofi/colors.rasi` |
| `dunstrc` | `dunst/dunstrc` |
| `nvim.lua` | `nvim/lua/core/highlights/colors.lua` |
| `icons.json` | `~/.cache/matugen/icons.json` |

The roles used most often are `background`, `surface`, `on_surface`, `on_surface_variant`, `primary`, `on_primary`, `outline`, and `error`. Hyprland maps them to `color0` through `color15`. CSS and Rofi use them as `@primary`, `@surface`, and `@on-surface`. The rest of the outputs, including wlogout, cava, btop, and Alacritty, are in `config.toml`.

## How the theme is triggered

`wallselect.sh` does three things: applies the wallpaper, copies it to `~/.config/hypr/hyprlock.png`, and runs `matugen` with the mode stored in `~/.local/share/blacknode/theme_mode`.

The mode is chosen in `wallpaper.sh` (Dark Mode or Light Mode) and written to `theme_mode`. It is not applied at that moment. It is used the next time you pick a wallpaper. If you switch modes and see no difference, pick the image again.

After `matugen`, the script restarts Dunst, sends `SIGUSR1` to Cava, and runs `killall -USR1 kitty`. Waybar reloads its CSS because `reload_style_on_change` is enabled. Hyprland reads `themes/colors.lua` at startup, so window borders do not change until you run `hyprctl reload` or restart the session.

## Adding an app to the theme

1. Create a template in `Configs/.config/matugen/templates/` using placeholders such as `{{colors.primary.default.hex}}`.
2. Add a block to `Configs/.config/matugen/config.toml`:

```toml
[templates.myapp]
input_path = '~/.config/matugen/templates/myapp.conf'
output_path = '~/.config/myapp/colors.conf'
post_hook = 'pkill -SIGUSR1 myapp'
```

3. Make the app read that file, then run `matugen image ~/Pictures/Wallpapers/some.jpg -m dark` and check the output.

## Shape

Window rounding is 8 px, gaps are 3 px inner and 7 px outer, and active borders use a 1 px gradient from `color0` to `color1`. Inactive windows sit at 0.9 opacity; Kitty and Spotify use 0.8. Blur uses size 6 with 3 passes.

The bar is 30 px high and groups its modules into `hollow-*` capsules. Those group names are CSS selectors. If you rename a group in `Layouts/blacknode.jsonc`, rename it in `style.css` or it loses its background, padding, and radius.

## Typography

JetBrainsMono Nerd Font appears in Kitty, Waybar, Dunst, Hyprlock, and several scripts. The installer only checks for `ttf-jetbrains-mono`, not the Nerd Font variant. If the Nerd variant is missing, icons render as boxes.

Hyprlock asks for `Inter Display Medium` in the greeting label. That font is not in the repo or in `packages.json`; without it, the label falls back to another font.

## Fixed color islands

| Piece | Palette | Can it join the pipeline? |
|---|---|---|
| Yazi | Catppuccin Mocha | Yes, but the palette is duplicated in `theme.toml` and `init.lua` |
| Fastfetch | blue and white | Yes; `config.jsonc` uses named colors, not theme roles |
| Clipse | gold and brown in `custom_theme.json` | Yes, but `config.json` points at `blacknode.json`, which no template generates |
| MPRIS icons | fixed Catppuccin colors in `mpris.jsonc` | Yes, if you replace the inline hex values with theme roles |

There is no rule that everything must follow `matugen`. The useful question is how often you see the piece. Yazi is open all day, so its palette is worth wiring. Fastfetch appears when you call it, so the cost is lower.

## Notifications and icons

Dunst uses the generated `dunstrc`. Icons live in `Configs/.config/dunst/assets/`. The files under `src/system/` contain the token `{{fill}}`. `recolor-icons.sh` copies them to `/tmp/blacknode-icons/` and replaces the token with `on_surface` from `~/.cache/matugen/icons.json`. The files under `weather/dark/` already have fixed colors and do not go through that process.

The script runs from `autostart.lua`. If it runs before `matugen` has produced `icons.json`, it uses `#ffffff`. If an icon does not appear, check `/tmp/blacknode-icons/` and the exact filename the script asks for.
