# BlackNode Architecture

BlackNode is a wallpaper-driven, matugen-colored Arch/Hyprland ecosystem. It
is composed of three layers that share one identity: **BlackNode**, accent
`#C9CBFF`, tagline *"Your home in the terminal."*

## Layers

```
┌─────────────────────────────────────────────────────────────┐
│  Identity / Orchestration   (blacknode CLI, version.json)    │
├─────────────────────────────────────────────────────────────┤
│  Adaptive layer    blacknode-brain · blacknode-learn · greeter │
│                    greeter · whatsnew · continuity · insight  │
├─────────────────────────────────────────────────────────────┤
│  Surface           waybar (profiles/layouts) · rofi (bn-menu) │
│  Presentation      matugen templates · awww wallpapers · themes│
└─────────────────────────────────────────────────────────────┘
```

### 1. Presentation (the look)
- **matugen** is the single source of truth for color. A wallpaper drives a
  Material-You palette that recolors kitty, waybar, rofi, dunst, hypr, cava,
  nvim, clipse, wlogout, btop via templates in `matugen/templates/`.
- **awww** sets the wallpaper (with transitions) and feeds `hyprlock.png`.
- Profiles (`music/study/coding/astronomy`) each own a wallpaper pool +
  waybar layout.

### 2. Surface (the UI)
- **waybar**: ~80 modules grouped into profile layouts (`waybar/Profiles/*`).
  Switching a profile rewrites `config.jsonc` includes and recolors.
- **rofi / bn-menu**: top-level hub → 19 submenu scripts + BlackNode modules.
- **theming**: `theme` submenu drives wallpaper + matugen + reload.

### 3. Adaptive identity (the differentiator)
Everything here is **local-only**: no network, no external models, nothing
leaves the machine. State lives under `~/.local/share/blacknode/`.
- `blacknode-brain` — modular cognitive engine. Pipeline:
  `Collector -> Algorithm -> DecisionEngine -> ActionEngine`. Each stage is a
  trait (`Collector`, `Algorithm`, `DecisionEngine`, `Action`), so new
  behavior is added without touching core. Algorithms (EWMA, Markov, Bayes,
  KMeans, anomaly, context-graph, reinforcement) publish `Knowledge`; the
  DecisionEngine fuses it into a `Context` belief and emits explainable
  `Decision`s; the ActionEngine runs real desktop effects (DND, HUD, power,
  wallpaper, brightness, profile). Config (`brain/config.toml`) toggles every
  stage per-feature. Source in `src/brain/`; built/installed to `~/.local/bin`
  by `linkdots.sh`.
- `blacknode-learn.py` — behavior learner writing `behavior.json`; the brain's
  `behavior_file` collector feeds on it.
- `blacknode-greeter` — contextual login greeter (phrase pool from repo).
- `blacknode-whatsnew` — changelog center (once-seen tracking).
- `blacknode-continuity` — session save/restore across suspend/poweroff.
- `blacknode-insight` — "Your Patterns" viewer over `behavior.json`.

## The `blacknode` command

`blacknode` is the front door to the whole ecosystem. It fronts every module
so the system feels like one product, not a folder of scripts:

| command | fronts |
|---------|--------|
| `blacknode version` | `version.json` |
| `blacknode doctor` | health check of all layers |
| `blacknode profile [name]` | `scripts/profiles/menu.sh` |
| `blacknode theme` | `scripts/theme/menu.sh` |
| `blacknode brain {start\|stop\|status\|explain\|state}` | `blacknode-brain` daemon |
| `blacknode patterns` | `blacknode-insight.sh` |
| `blacknode whatsnew` | `blacknode-whatsnew.sh` |
| `blacknode greet` | `blacknode-greeter.sh` |
| `blacknode continuity {save\|restore}` | `blacknode-continuity.sh` |

## Privacy

The adaptive layer only ever reads the *class* of the active window and
counters derived from your actions. It never reads content, never uploads,
and never calls external models. Model state is fixed-size and persisted
atomically under `~/.local/share/blacknode/brain/`.

## Roadmap (next)

- Branding kit (SVG/logo) shared across greeter, waybar, rofi, SDDM, GRUB.
- `blacknode sync` to pull repo updates (phrases, changelog, profiles).
- Richer HUD layouts per context (media, study, browsing) driven by the brain.
