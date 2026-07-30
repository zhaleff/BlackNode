#!/usr/bin/env bash
exec python3 << 'BNPY'
import sys, os, signal, time, subprocess, re
sys.path.insert(0, os.path.expanduser("~/.local/lib"))
from blacknode.psyche.core import PsychEngine
from blacknode.notify.engine import NotifEngine
from blacknode.resources import resolve

engine = PsychEngine()
notifier = NotifEngine()
signal.signal(signal.SIGTERM, lambda *_: exit(0))
signal.signal(signal.SIGINT, lambda *_: exit(0))

ASSETS = os.path.expanduser("~/.config/dunst/assets")
REPLACE_ID = 2595
COOLDOWN = 15

prev_state = "unknown"
prev_ssid = ""
prev_signal = -999
last_notif = 0.0

def get_wifi_state():
    try:
        route = subprocess.run(["ip", "route"], capture_output=True, text=True, timeout=3).stdout
        iface = None
        for line in route.splitlines():
            if line.startswith("default"):
                parts = line.split()
                if len(parts) > 4:
                    iface = parts[4]
                    break
        if not iface:
            iface = _find_wifi_iface()
        if not iface:
            return "disabled", "", 0

        rfkill = subprocess.run(["rfkill", "list", "wifi"], capture_output=True, text=True, timeout=3).stdout
        if "Soft blocked: yes" in rfkill or "Hard blocked: yes" in rfkill:
            return "disabled", "", 0

        oper = subprocess.run(["ip", "link", "show", iface], capture_output=True, text=True, timeout=3).stdout
        if "state UP" not in oper and "state UNKNOWN" not in oper:
            return "disconnected", "", 0

        link = subprocess.run(["iw", "dev", iface, "link"], capture_output=True, text=True, timeout=3).stdout
        ssid = ""
        sig = 0
        m = re.search(r"SSID:\s*(.+)", link)
        if m:
            ssid = m.group(1).strip()
        m = re.search(r"signal:\s*(-?\d+)", link)
        if m:
            sig = int(m.group(1))

        if not ssid:
            return "no_network", "", 0

        return "connected", ssid, sig
    except Exception:
        return "unknown", "", 0

def _find_wifi_iface():
    try:
        out = subprocess.run(["iw", "dev"], capture_output=True, text=True, timeout=3).stdout
        for line in out.splitlines():
            if "Interface" in line:
                return line.split()[-1]
    except: pass
    return None

def icon_for(state, sig):
    if state == "connected":
        if sig >= -50: return os.path.join(ASSETS, "wifi-strong.svg")
        if sig >= -70: return os.path.join(ASSETS, "wifi-medium.svg")
        return os.path.join(ASSETS, "wifi-low.svg")
    MAP = {
        "disconnected": "wifi-disconnected.svg",
        "disabled": "wifi-disabled.svg",
        "no_network": "wifi-no-network.svg",
        "hotspot": "wifi-hotspot.svg",
        "unknown": "wifi-unknown.svg",
    }
    f = MAP.get(state, "wifi-unknown.svg")
    return os.path.join(ASSETS, f)

def message_for(state, ssid, sig, prev_st, prev_sid, prev_sig):
    t = time.time()
    if state == "connected":
        if prev_st != "connected":
            return (
                f"You connected to {ssid}. Your network, your call.",
                f"Conectado a {ssid}",
                "normal", 5000,
            )
        if ssid != prev_sid:
            return (
                f"Switched to {ssid}. Better signal where you moved.",
                f"Red cambiada: {ssid}",
                "low", 4000,
            )
        if prev_st == "connected" and sig > -50 and prev_sig <= -50:
            return (
                f"Signal recovered on {ssid}. Solid at {abs(sig)} dBm.",
                f"Signal recovered",
                "low", 4000,
            )
        if sig <= -80 and prev_sig > -80:
            return (
                f"Signal very weak on {ssid} ({abs(sig)} dBm). You might lose it.",
                f"Critical signal",
                "normal", 6000,
            )
        return None

    if state == "disconnected":
        if prev_st == "connected":
            return (
                f"{ssid or 'Network'} dropped. I'll let you know when it's back.",
                f"Desconectado",
                "normal", 5000,
            )
        return None

    if state == "disabled":
        if prev_st != "disabled":
            return (
                "WiFi turned off. You chose focus.",
                "WiFi apagado",
                "low", 4000,
            )
        return None

    if state == "no_network":
        if prev_st == "connected":
            return (
                f"{ssid or 'Network'} out of range. No networks in sight.",
                f"Sin redes",
                "low", 4000,
            )
        return None

    if state == "unknown":
        return (
            "WiFi state unclear. Checking again.",
            "WiFi desconocido",
            "low", 3000,
        )
    return None

while True:
    state, ssid, sig = get_wifi_state()

    msg = message_for(state, ssid, sig, prev_state, prev_ssid, prev_signal)

    if msg:
        body, title, urgency, timeout = msg
        ico = icon_for(state, sig)
        from blacknode.notify.envelope import NotificationEnvelope
        env = NotificationEnvelope(
            title=title, body=body, icon=ico,
            urgency=urgency, timeout=timeout,
            replace_id=REPLACE_ID, app_name="WiFi",
        )
        notifier.send(env)
        last_notif = time.time()

    prev_state, prev_ssid, prev_signal = state, ssid, sig
    time.sleep(3)
BNPY