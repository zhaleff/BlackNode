#!/usr/bin/env bash
exec python3 << 'BNPY'
import sys, os
sys.path.insert(0, os.path.expanduser("~/.local/lib"))
from blacknode.sensors.audio import get_sink_volume
from blacknode.notify.composers import compose_volume
from blacknode.psyche.core import PsychEngine
from blacknode.notify.engine import NotifEngine
engine = PsychEngine()
notifier = NotifEngine()
vol, _ = get_sink_volume()
notifier.send(compose_volume(engine, vol))
BNPY