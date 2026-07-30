#!/usr/bin/env bash
exec python3 << 'BNPY'
import sys, os, time, subprocess, atexit, tempfile
sys.path.insert(0, os.path.expanduser("~/.local/lib"))
from blacknode.psyche.core import PsychEngine
from blacknode.notify.engine import NotifEngine
from blacknode.notify.composers import compose_media
from blacknode.resources import resolve

engine = PsychEngine()
notifier = NotifEngine()
prev = ""

def pctl(*a, **kw):
    return subprocess.run(["playerctl"] + list(a), capture_output=True, text=True, timeout=5)

while True:
    st = pctl("status").stdout.strip()
    if st == "Playing":
        title = pctl("metadata", "title").stdout.strip()
        artist = pctl("metadata", "artist").stdout.strip()
        art = pctl("metadata", "mpris:artUrl").stdout.strip()
        key = f"{title}-{artist}"

        if key and key != prev:
            envelope = compose_media(engine, title, artist, art, st)
            notifier.send(envelope)
            prev = key

    time.sleep(2)
BNPY