#!/usr/bin/env python3
import json
import subprocess

PLAYER_ICONS = {
    "spotify": "\uf8a6",
    "firefox": "\uf269",
    "youtube-music": "\uf16a",
    "vlc": "\ued58",
    "mpv": "\uf039",
}

def get_active_player():
    try:
        output = subprocess.check_output(
            ["playerctl", "metadata", "--format", "{{playerName}}", "--all-players"],
            stderr=subprocess.DEVNULL, timeout=2
        ).decode().strip()
        if not output:
            return None
        for line in output.split("\n"):
            name = line.strip().lower()
            if name:
                return name
        return None
    except Exception:
        return None

def is_playing():
    try:
        status = subprocess.check_output(
            ["playerctl", "status", "--all-players"],
            stderr=subprocess.DEVNULL, timeout=1
        ).decode().strip()
        return "Playing" in status
    except Exception:
        return False

def main():
    player = get_active_player()
    playing = is_playing()

    if player and playing:
        icon = PLAYER_ICONS.get(player, "\uf001")
        tooltip = f"Playing on {player.title()}"
        cls = "playing"
    elif player:
        icon = PLAYER_ICONS.get(player, "\uf001")
        tooltip = f"Paused on {player.title()}"
        cls = "paused"
    else:
        icon = "\uf001"
        tooltip = "No active player"
        cls = "stopped"

    print(json.dumps({
        "text": icon,
        "tooltip": tooltip,
        "class": cls,
        "alt": cls
    }, ensure_ascii=False))

if __name__ == "__main__":
    main()
