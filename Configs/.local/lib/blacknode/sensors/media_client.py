import subprocess
import json


def get_active_player() -> str | None:
    out = subprocess.run(
        ["playerctl", "-l"],
        capture_output=True, text=True, timeout=5,
    ).stdout.strip().splitlines()
    for p in out:
        p = p.strip()
        if not p:
            continue
        status = subprocess.run(
            ["playerctl", "-p", p, "status"],
            capture_output=True, text=True, timeout=3,
        ).stdout.strip()
        if status == "Playing":
            return p
    return out[0] if out else None


def get_metadata(player: str) -> dict:
    out = subprocess.run(
        ["playerctl", "-p", player, "metadata", "-f",
         '{"title":"{{title}}","artist":"{{artist}}","artUrl":"{{mpris:artUrl}}","status":"{{status}}"}'],
        capture_output=True, text=True, timeout=5,
    ).stdout.strip()
    try:
        return json.loads(out)
    except (json.JSONDecodeError, ValueError):
        return {"title": "Unknown", "artist": "Unknown", "artUrl": "", "status": "Stopped"}


def follow_metadata(timeout: int = 30) -> None:
    try:
        subprocess.run(
            ["playerctl", "--follow", "metadata", "-f", "change"],
            capture_output=True, text=True, timeout=timeout,
        )
    except subprocess.TimeoutExpired:
        pass
