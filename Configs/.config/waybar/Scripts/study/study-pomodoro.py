#!/usr/bin/env python3
import json
import os
import subprocess

STATE_FILE = "/tmp/blacknode_pomodoro"


def load_state():
    try:
        with open(STATE_FILE) as f:
            parts = f.read().strip().split("|")
        mode = parts[0] if len(parts) > 0 else "idle"
        remaining = int(parts[1]) if len(parts) > 1 else 0
        paused = parts[2] == "true" if len(parts) > 2 else False
        return mode, remaining, paused
    except Exception:
        return "idle", 0, False


def fmt(s):
    m = s // 60
    sec = s % 60
    return f"{m:02d}:{sec:02d}"


def main():
    mode, remaining, paused = load_state()

    if mode == "idle":
        text = "\uf0dc"
        tooltip = "Pomodoro: idle\nClick to start a focus session"
        cls = "idle"
    elif mode == "work":
        label = "Focus" if not paused else "Paused"
        icon = "\uf0dc" if not paused else "\uf04c"
        text = f"{icon} {fmt(remaining)}"
        tooltip = f"Pomodoro: {label}\n{fmt(remaining)} left\nClick to manage"
        cls = "work" if not paused else "paused"
    else:  # break
        icon = "\uf0dc" if not paused else "\uf04c"
        text = f"{icon} {fmt(remaining)}"
        tooltip = f"Pomodoro: Break\n{fmt(remaining)} left\nClick to manage"
        cls = "break" if not paused else "paused"

    print(json.dumps({"text": text, "tooltip": tooltip, "class": cls, "alt": cls}, ensure_ascii=False))


if __name__ == "__main__":
    main()
