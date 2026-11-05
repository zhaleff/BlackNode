# Notification icons

One directory is one domain. The domain name says what the icon represents, not
where it is used. The same icon can serve dunst, rofi, waybar, or any script
without a copy.

## Layout

```
icons/
├── appearance/     visual style (wallpaper)
├── battery/        power and charge
├── bluetooth/      adapter and connection state
├── device/         connected hardware (usb)
├── display/        screen and brightness
├── keyboard/       keyboard and lock (caps lock)
├── network/        connectivity (wifi)
├── pomodoro/       timer
├── privacy/        sensors and permissions (mic)
├── recording/      screen capture
├── system/         system events (error, reload, whatsnew)
└── volume/         audio
```

## Rules that keep the tree scalable

1. One icon belongs to one domain. If an icon fits two, put it in the domain of
   the concept, not the script that calls it.
2. The filename names the state, not the action: `wifi-disconnected`,
   `battery-low`, `mic-off`. Drop the domain prefix because the path already
   carries it.
3. Add subdirectories only when a domain grows. `network/vpn/…` earns its place
   when several VPN icons exist, not for one file.
4. No redundant prefixes. `battery/battery-low.svg` could become
   `battery/low.svg`, but keep the current name while scripts reference it.

## Volatility

Domains are grouped by how often they change, not by importance.

| Level | Domains | Change rate |
| --- | --- | --- |
| High | `volume`, `battery`, `display` | Every keypress |
| Medium | `network`, `bluetooth`, `privacy`, `keyboard` | On connect or disconnect |
| Low | `system`, `appearance`, `device`, `recording`, `pomodoro` | One-off events |

High-volatility icons should be minimal SVGs without gradients. They get
recolored and rendered many times. Low-volatility icons can carry more detail.

## Notification text

The icon supports the text. Every script follows the same split:

- Summary: domain or event name (`WiFi`, `Brightness`, `USB`).
- Body: the concrete state (`Home connected`, `42%`, `Mouse disconnected`).
- Icon on the left (`icon_position = left` in `dunstrc`).

Never put the state only in the icon. If the SVG fails, the message still has to
read.

## How scripts consume the tree

`recolor-icons.sh` walks this tree and mirrors it under
`/tmp/blacknode-icons/`, replacing `{{fill}}` with the matugen color. Scripts
never point at the source SVG:

```bash
ICON="/tmp/blacknode-icons/display/brightness.svg"
```

When you move or rename an icon, update every old
`/tmp/blacknode-icons/...` path in `~/.local/bin` and `~/.config/rofi`.
