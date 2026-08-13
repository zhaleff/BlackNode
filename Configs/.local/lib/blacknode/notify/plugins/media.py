from __future__ import annotations

import hashlib
import subprocess
import time
from pathlib import Path

from ..context import NotificationContext
from ..envelope import NotificationEnvelope

POLL_SECONDS = 2

ART_DIR = Path.home() / ".cache" / "blacknode" / "media-art"


def _art_hash(art: str) -> str:
    return hashlib.sha256(art.encode()).hexdigest()[:16]


def _prune(keep: Path) -> None:
    for f in ART_DIR.glob("*.jpg"):
        if f != keep:
            try:
                f.unlink()
            except OSError:
                pass


def _resolve_art(ctx: NotificationContext, art: str, icon: str) -> str:
    if art.startswith("file://"):
        return art.removeprefix("file://")
    if art.startswith("https://"):
        ART_DIR.mkdir(parents=True, exist_ok=True)
        tmp = ART_DIR / f"{_art_hash(art)}.jpg"
        if not tmp.exists():
            subprocess.run(
                ["curl", "-sf", "--max-time", "3", "-o", str(tmp), art],
                capture_output=True,
                timeout=5,
            )
            if tmp.exists() and tmp.stat().st_size > 1000:
                _prune(tmp)
        if tmp.exists() and tmp.stat().st_size > 1000:
            return str(tmp)
    return icon


def handle(ctx: NotificationContext) -> NotificationEnvelope:
    title = ctx.get("title", "")
    artist = ctx.get("artist", "")
    art = ctx.get("art", "")
    body = ctx.collapse(
        fallback=f"{title} — {artist}",
        title=title,
        artist=artist,
        status="Playing",
    )
    icon = _resolve_art(ctx, art, ctx.icon("music-note", "audio-x-generic", "multimedia-player"))
    return ctx.envelope(
        title="Playing",
        body=body,
        icon=icon,
        urgency="low",
        timeout=5000,
        replace_id=2596,
        app_name="Media",
    )


def _pctl(*args):
    return subprocess.run(
        ["playerctl"] + list(args),
        capture_output=True,
        text=True,
        timeout=5,
    )


def run(service) -> None:
    prev = ""
    while True:
        status = _pctl("status").stdout.strip()
        if status == "Playing":
            title = _pctl("metadata", "title").stdout.strip()
            artist = _pctl("metadata", "artist").stdout.strip()
            art = _pctl("metadata", "mpris:artUrl").stdout.strip()
            key = f"{title}-{artist}"
            if key and key != prev:
                service.notify("media", title=title, artist=artist, art=art, status=status)
                prev = key
        time.sleep(POLL_SECONDS)