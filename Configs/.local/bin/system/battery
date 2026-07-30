#!/usr/bin/env bash
exec python3 << 'BNPY'
import sys, os, signal, time
sys.path.insert(0, os.path.expanduser("~/.local/lib"))
from blacknode.sensors.power import get_battery
from blacknode.notify.composers import compose_battery
from blacknode.psyche.core import PsychEngine
from blacknode.notify.engine import NotifEngine
engine = PsychEngine()
notifier = NotifEngine()
signal.signal(signal.SIGTERM, lambda *_: exit(0))
signal.signal(signal.SIGINT, lambda *_: exit(0))
prev = (None, None)
while True:
    cap, status = get_battery()
    if cap is not None and status is not None:
        pc, ps = prev
        if status != ps or (status == "Discharging" and cap <= 15 and (pc if pc is not None else 100) > 15) or (status == "Discharging" and cap <= 5 and (pc if pc is not None else 100) > 5) or (status == "Charging" and cap >= 80 and (pc if pc is not None else 0) < 80):
            e = compose_battery(engine, cap, status, pc, ps)
            if e: notifier.send(e)
        prev = (cap, status)
    time.sleep(30)
BNPY