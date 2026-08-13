from __future__ import annotations

import re
import subprocess
import time

from ..context import NotificationContext
from ..envelope import NotificationEnvelope

POLL_SECONDS = 3


def _find_wifi_iface() -> str | None:
    try:
        out = subprocess.run(["iw", "dev"], capture_output=True, text=True, timeout=3).stdout
        for line in out.splitlines():
            if "Interface" in line:
                return line.split()[-1]
    except Exception:
        pass
    return None


def _wifi_state() -> tuple[str, str, int]:
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
        match = re.search(r"SSID:\s*(.+)", link)
        if match:
            ssid = match.group(1).strip()
        match = re.search(r"signal:\s*(-?\d+)", link)
        if match:
            sig = int(match.group(1))

        if not ssid:
            return "no_network", "", 0
        return "connected", ssid, sig
    except Exception:
        return "unknown", "", 0


def _icon_for(ctx: NotificationContext, state: str, sig: int) -> str:
    if state == "connected":
        if sig >= -50:
            return ctx.icon("wifi-strong")
        if sig >= -70:
            return ctx.icon("wifi-medium")
        return ctx.icon("wifi-low")
    mapping = {
        "disconnected": "wifi-disconnected",
        "disabled": "wifi-disabled",
        "no_network": "wifi-no-network",
        "hotspot": "wifi-hotspot",
        "unknown": "wifi-unknown",
    }
    return ctx.icon(mapping.get(state, "wifi-unknown"))


def _message_for(state, ssid, sig, prev_state, prev_ssid, prev_sig):
    if state == "connected":
        if prev_state != "connected":
            return (
                f"You connected to {ssid}. Your network, your call.",
                "Connected to " + ssid,
                "normal",
                5000,
            )
        if ssid != prev_ssid:
            return (
                f"Switched to {ssid}. Better signal where you moved.",
                "Network changed: " + ssid,
                "low",
                4000,
            )
        if prev_state == "connected" and sig > -50 and prev_sig <= -50:
            return (
                f"Signal recovered on {ssid}. Solid at {abs(sig)} dBm.",
                "Signal recovered",
                "low",
                4000,
            )
        if sig <= -80 and prev_sig > -80:
            return (
                f"Signal very weak on {ssid} ({abs(sig)} dBm). You might lose it.",
                "Critical signal",
                "normal",
                6000,
            )
        return None

    if state == "disconnected":
        if prev_state == "connected":
            return (
                f"{ssid or 'Network'} dropped. I'll let you know when it's back.",
                "Disconnected",
                "normal",
                5000,
            )
        return None

    if state == "disabled":
        if prev_state != "disabled":
            return (
                "WiFi turned off. You chose focus.",
                "WiFi off",
                "low",
                4000,
            )
        return None

    if state == "no_network":
        if prev_state == "connected":
            return (
                f"{ssid or 'Network'} out of range. No networks in sight.",
                "No networks",
                "low",
                4000,
            )
        return None

    if state == "unknown":
        return (
            "WiFi state unclear. Checking again.",
            "WiFi unknown",
            "low",
            3000,
        )
    return None


def handle(ctx: NotificationContext) -> NotificationEnvelope | None:
    state = ctx.get("state")
    ssid = ctx.get("ssid", "") or ""
    sig = ctx.get("signal", 0)
    prev_state = ctx.get("prev_state")
    prev_ssid = ctx.get("prev_ssid", "") or ""
    prev_sig = ctx.get("prev_signal", -999)
    message = _message_for(state, ssid, sig, prev_state, prev_ssid, prev_sig)
    if not message:
        return None
    body, title, urgency, timeout = message
    return ctx.envelope(
        title=title,
        body=body,
        icon=_icon_for(ctx, state, sig),
        urgency=urgency,
        timeout=timeout,
        replace_id=2595,
        app_name="WiFi",
    )


def run(service) -> None:
    prev_state = "unknown"
    prev_ssid = ""
    prev_signal = -999
    while True:
        state, ssid, sig = _wifi_state()
        service.notify(
            "wifi",
            state=state,
            ssid=ssid,
            signal=sig,
            prev_state=prev_state,
            prev_ssid=prev_ssid,
            prev_signal=prev_signal,
        )
        prev_state, prev_ssid, prev_signal = state, ssid, sig
        time.sleep(POLL_SECONDS)
