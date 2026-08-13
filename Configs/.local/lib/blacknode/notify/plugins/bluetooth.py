from __future__ import annotations

import re
import subprocess
import time

from ..context import NotificationContext
from ..envelope import NotificationEnvelope

POLL_SECONDS = 5
BATTERY_THRESHOLDS = (5, 10, 15, 20)


def _band(percent: int) -> int | None:
    for threshold in BATTERY_THRESHOLDS:
        if percent <= threshold:
            return threshold
    return None


def _ctl(*args) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["bluetoothctl"] + list(args),
        capture_output=True,
        text=True,
        timeout=8,
    )


def _adapter_state() -> tuple[bool | None, bool | None]:
    out = _ctl("show").stdout
    powered = discoverable = None
    for line in out.splitlines():
        stripped = line.strip()
        if stripped.startswith("Powered:"):
            powered = stripped.split(":")[1].strip() == "yes"
        elif stripped.startswith("Discoverable:"):
            discoverable = stripped.split(":")[1].strip() == "yes"
    return powered, discoverable


def _connected_devices() -> dict[str, str]:
    out = _ctl("devices", "Connected").stdout
    result: dict[str, str] = {}
    for line in out.splitlines():
        match = re.match(r"Device\s+([0-9A-F:]{17})\s+(.+)", line, re.I)
        if match:
            result[match.group(1).upper()] = match.group(2).strip()
    return result


def _battery_percent(mac: str) -> int | None:
    out = _ctl("info", mac).stdout
    for line in out.splitlines():
        if line.strip().startswith("Battery Percentage"):
            match = re.search(r"\((\d+)\)", line)
            if match:
                return int(match.group(1))
            match = re.search(r":\s*0x([0-9a-fA-F]+)", line)
            if match:
                return int(match.group(1), 16)
    upower_path = f"/org/freedesktop/UPower/devices/headset_dev_{mac.lower().replace(':', '_')}"
    out = subprocess.run(["upower", "-i", upower_path], capture_output=True, text=True, timeout=5).stdout
    if "should be ignored" in out or "(null)" in out:
        return None
    for line in out.splitlines():
        stripped = line.strip()
        if stripped.startswith("percentage"):
            try:
                return int(stripped.split()[1].rstrip("%"))
            except (ValueError, IndexError):
                pass
    return None


def handle(ctx: NotificationContext) -> NotificationEnvelope | None:
    event = ctx.get("event")
    name = ctx.get("name", "")
    percent = ctx.get("percent", None)

    if event == "battery":
        band = _band(percent or 0)
        critical = band is not None and band <= 10
        return ctx.envelope(
            title="Bluetooth low battery",
            body=f"{name} at {percent}%.",
            icon=ctx.icon("battery-low", "battery-critical"),
            urgency="critical" if critical else "normal",
            timeout=0 if critical else 8000,
            replace_id=ctx.get("replace_id", 2600),
            app_name="Bluetooth",
        )

    if event == "power_off":
        return ctx.envelope(
            title="Bluetooth off",
            body="Radio disabled. Connections paused.",
            icon=ctx.icon("bluetooth-off", "bluetooth"),
            urgency="low",
            timeout=4000,
            replace_id=2602,
            app_name="Bluetooth",
        )

    if event == "power_on":
        return ctx.envelope(
            title="Bluetooth on",
            body="Radio enabled.",
            icon=ctx.icon("bluetooth", "bluetooth-connected"),
            urgency="low",
            timeout=4000,
            replace_id=2602,
            app_name="Bluetooth",
        )

    if event == "discoverable":
        return ctx.envelope(
            title="Discoverable",
            body="Searching for devices...",
            icon=ctx.icon("bluetooth-searching", "bluetooth"),
            urgency="low",
            timeout=4000,
            replace_id=2603,
            app_name="Bluetooth",
        )

    if event == "connect":
        return ctx.envelope(
            title="Connected",
            body=f"{name} connected.",
            icon=ctx.icon("bluetooth-connected", "bluetooth"),
            urgency="low",
            timeout=4000,
            replace_id=2602,
            app_name="Bluetooth",
        )

    if event == "disconnect":
        return ctx.envelope(
            title="Disconnected",
            body=f"{name} disconnected.",
            icon=ctx.icon("bluetooth", "bluetooth-connected"),
            urgency="low",
            timeout=3000,
            replace_id=2602,
            app_name="Bluetooth",
        )

    return None


def _replace_id(mac: str) -> int:
    return 2700 + (int(mac.replace(":", ""), 16) % 100)


def run(service) -> None:
    prev_powered = None
    prev_discoverable = None
    prev_connected: dict[str, str] = {}
    prev_battery: dict[str, int] = {}

    while True:
        powered, discoverable = _adapter_state()

        if prev_powered is not None and powered is not None and powered != prev_powered:
            service.notify("bluetooth", event="power_on" if powered else "power_off")
            prev_battery.clear()
        prev_powered = powered

        if powered:
            if discoverable and (not prev_discoverable):
                service.notify("bluetooth", event="discoverable")
            prev_discoverable = discoverable

            connected = _connected_devices()
            for mac, name in connected.items():
                if mac not in prev_connected:
                    service.notify("bluetooth", event="connect", name=name, mac=mac)
                percent = _battery_percent(mac)
                if percent is not None:
                    band = _band(percent)
                    previous = prev_battery.get(mac)
                    if band is not None and band != previous and (previous is None or band < previous):
                        prev_battery[mac] = band
                        service.notify(
                            "bluetooth",
                            event="battery",
                            name=name,
                            mac=mac,
                            percent=percent,
                            replace_id=_replace_id(mac),
                        )

            for mac in prev_connected:
                if mac not in connected:
                    prev_battery.pop(mac, None)
                    service.notify(
                        "bluetooth",
                        event="disconnect",
                        name=prev_connected[mac],
                        mac=mac,
                    )
            prev_connected = connected

        time.sleep(POLL_SECONDS)