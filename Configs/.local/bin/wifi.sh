#!/usr/bin/env bash
exec python3 << 'BNPY'
import sys, os, signal, time
sys.path.insert(0, os.path.expanduser("~/.local/lib"))
from blacknode.sensors.network import get_wifi_state
from blacknode.notify.composers import compose_wifi
from blacknode.psyche.core import PsychEngine
from blacknode.notify.engine import NotifEngine
engine = PsychEngine()
notifier = NotifEngine()
signal.signal(signal.SIGTERM, lambda *_: exit(0))
signal.signal(signal.SIGINT, lambda *_: exit(0))
prev = ""
while True:
    state, ssid, sig = get_wifi_state()
    if state != prev:
        notifier.send(compose_wifi(engine, state, ssid, sig))
        prev = state
    time.sleep(5)
BNPY