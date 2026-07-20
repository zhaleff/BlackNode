# BlackNode Brain v2 — The Desktop That Acts on Its Own

**Release announcement**

BlackNode Brain has been rebuilt from scratch as a modular cognitive engine.
It no longer just watches you. It learns your routine and acts on it — but
always with your permission.

## What it is

A local-only pipeline that turns raw desktop signals into real actions:

```
Collector  ->  Algorithm  ->  DecisionEngine  ->  ActionEngine
```

- **Collectors** observe the active window (Hyprland) and your focus/distract
  events from `blacknode-learn.py`.
- **Algorithms** are independent, incremental ML primitives: EWMA focus,
  Markov transitions, naive-Bayes focus-by-hour, online K-Means, Welford
  anomaly detection, a temporal context graph, a contextual bandit
  (reinforcement), and a **routine learner**.
- The **DecisionEngine** fuses the evidence into a belief about what you are
  doing and emits *explainable* decisions (`blacknode brain explain` shows why).
- The **ActionEngine** runs real desktop effects: Do-Not-Disturb, dynamic HUD,
  power profile, wallpaper, brightness, profile switch, and launching apps.

Everything stays on your machine. No network, no external models.

## The headline feature: it opens your apps for you — after asking

The new `routine` algorithm watches which application you open at which hour.
After a few days it knows: *"around 22:00 you always open Spotify."*

When that hour arrives, the brain does not launch anything blindly. It opens a
small prompt (`brain-suggest.sh`, a rofi dialog):

```
BlackNode learned you usually open 'spotify' now. Open it?
  Yes
  No
```

Only if you answer **Yes** does it launch the app. Decline and it stays quiet.
This is the brain acting autonomously, but on your terms.

## Explainability

Every decision carries its reasons. Ask the brain why it did something:

```
$ blacknode brain explain
last decision: LaunchApp
confidence:    0.91
why:
  - learned routine: you usually open spotify now (p=91%)
```

## Granular control

Every algorithm and every action is individually toggleable in
`~/.local/share/blacknode/brain/config.toml`. You can demote the brain to a
passive monitor, turn off launching, or disable any single primitive without
touching the code.

## Try it

```sh
./Scripts/linkdots.sh          # builds and installs blacknode-brain
blacknode brain start          # launched automatically by autostart
blacknode brain status         # current inferred context
blacknode brain explain        # last decision + reasons
```

The brain learns from your real usage. The more you use your desktop, the more
it knows when to step in — and when to leave you alone.
