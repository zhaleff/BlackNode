#!/usr/bin/env bash
exec python3 << 'BNPY'
import sys, os, signal, subprocess
sys.path.insert(0, os.path.expanduser("~/.local/lib"))
from blacknode.psyche.core import PsychEngine
from blacknode.notify.engine import NotifEngine
from blacknode.notify.composers import compose_device

engine = PsychEngine()
notifier = NotifEngine()

signal.signal(signal.SIGTERM, lambda *_: exit(0))
signal.signal(signal.SIGINT, lambda *_: exit(0))

def device_name(path):
    try:
        props = subprocess.run(["udevadm","info","--query=property",f"--path={path}"],
                               capture_output=True, text=True, timeout=5).stdout
        for line in props.splitlines():
            if line.startswith("ID_MODEL=") or line.startswith("NAME="):
                v = line.split("=",1)[1].strip('"').replace("_"," ")
                if v: return v
    except: pass
    return None

proc = subprocess.Popen(["udevadm","monitor","--subsystem-match=input","--subsystem-match=usb","--udev"],
                        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, bufsize=1)

for line in proc.stdout:
    l = line.lower()
    action = ""
    if "bind" in l or ("add" in l and "remove" not in l and "unbind" not in l):
        action = "add"
    elif "remove" in l or "unbind" in l:
        action = "remove"
    else:
        continue
    name = device_name(line.strip().split()[-1]) or "device"
    envelope = compose_device(engine, action, name)
    if envelope:
        notifier.send(envelope)

proc.terminate()
BNPY