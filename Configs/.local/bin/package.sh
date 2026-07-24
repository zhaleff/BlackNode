#!/usr/bin/env bash
exec python3 << 'BNPY'
import sys, os
sys.path.insert(0, os.path.expanduser("~/.local/lib"))
from blacknode.sensors.packages import count_updates
from blacknode.notify.composers import compose_package
from blacknode.psyche.core import PsychEngine
from blacknode.notify.engine import NotifEngine
engine = PsychEngine()
notifier = NotifEngine()
official, aur = count_updates()
total = official + aur
if total > 0:
    notifier.send(compose_package(engine, total, official, aur))
BNPY