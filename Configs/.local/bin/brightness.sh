#!/usr/bin/env bash
exec python3 << 'BNPY'
import sys, os
sys.path.insert(0, os.path.expanduser("~/.local/lib"))
from blacknode.sensors.display import get_brightness
from blacknode.notify.composers import compose_brightness
from blacknode.psyche.core import PsychEngine
from blacknode.notify.engine import NotifEngine
engine = PsychEngine()
notifier = NotifEngine()
notifier.send(compose_brightness(engine, get_brightness()))
BNPY