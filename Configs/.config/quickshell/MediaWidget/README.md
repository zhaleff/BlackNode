# MediaWidget — Quickshell media panel

## Structure
```
MediaWidget/
├── shell.qml                 entry point, PanelWindow + IPC toggle
├── Theme.qml                 singleton, colors/spacing/radius
├── MediaPanel.qml            main layout
├── components/
│   ├── AlbumArt.qml          left side, centered, 24px vertical padding
│   ├── PlaybackControls.qml  shuffle / prev / play-pause / next / repeat
│   ├── ProgressIndicator.qml native wavy progress bar (Canvas, M3-style)
│   └── LyricsView.qml        synced lyrics, centered, line reveal
└── services/
    └── LyricsService.qml     fetches synced lyrics from lrclib.net (no API key)
```

## Install
Copy the whole `MediaWidget/` folder into your Quickshell config, typically:
```
~/.config/quickshell/MediaWidget/
```
Register it as a scope/config Quickshell loads, or run it standalone:
```
qs -c MediaWidget
```
Or by path:
```
qs -p ~/.config/quickshell/MediaWidget
```

## Requirements
- Quickshell with `Quickshell.Services.Mpris` and `Quickshell.Wayland` modules
- `qs` CLI available (comes with Quickshell) for IPC calls
- A layer-shell compositor (Hyprland is fine)

## Connect it to Waybar
The panel starts hidden. Toggle it from your existing `custom/media` module
in Waybar by adding the ipc call to `on-click`:

```jsonc
"custom/media": {
    "exec": "~/.config/waybar/Scripts/Media/media.sh show",
    "return-type": "json",
    "interval": 2,
    "on-click": "qs ipc -c MediaWidget call mediaPanel toggle",
    "escape": false
}
```

Your bash `custom/media` module keeps working exactly as-is for the bar
itself (title, No music fallback, etc). Clicking it now also opens/closes
this richer panel. Play/pause/next/previous inside the panel talk directly
to MPRIS, independent from the bash script.

## Notes / things to tune yourself
- `Theme.qml` colors are a guess at your palette (dark surface + cream/tan
  primary). Swap the hex values for your real `colors.css` values.
- `ProgressIndicator.qml` amplitude/wavelength are set to a subtle wave —
  tweak `amplitude` and `wavelength` inside the Canvas for a stronger/weaker
  effect.
- `LyricsService.qml` queries lrclib.net by artist+title+album+duration. If a
  track isn't found there, `available` becomes false and the panel shows
  "No lyrics found" — no fallback provider is wired in yet.
- The line-reveal mask in `LyricsView.qml` is a first pass (a rectangle that
  shrinks over the current line based on elapsed time between LRC
  timestamps). It's the "loading in" behavior you asked for, but since LRC
  only gives per-line timing (not per-word), the reveal is linear across the
  whole line rather than synced to actual word timing — worth revisiting if
  you want real word-level karaoke.
- No window-open animation yet (panel just appears when `visible` flips) —
  add an `opacity`/`y` `Behavior` on the `PanelWindow` content if you want a
  slide/fade-in.
