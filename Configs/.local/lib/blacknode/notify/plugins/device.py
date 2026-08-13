from __future__ import annotations

import subprocess

from ..context import NotificationContext
from ..envelope import NotificationEnvelope


def handle(ctx: NotificationContext) -> NotificationEnvelope:
    action = ctx.get("action", "add")
    name = ctx.get("name", "device")
    icon = ctx.icon("usb", "drive-removable-media", "device")
    if action == "add":
        body = ctx.collapse(fallback=f"{name} connected", device=name)
        title = "Device connected"
    else:
        body = ctx.collapse(fallback=f"{name} disconnected", device=name)
        title = "Device removed"
    return ctx.envelope(
        title=title,
        body=body,
        icon=icon,
        urgency="low",
        timeout=5000,
        replace_id=2597,
        app_name="Device",
    )


def _props(path: str) -> dict[str, str]:
    try:
        out = subprocess.run(
            ["udevadm", "info", "--query=property", f"--path={path}"],
            capture_output=True,
            text=True,
            timeout=5,
        ).stdout
        result: dict[str, str] = {}
        for line in out.splitlines():
            if "=" in line:
                key, _, value = line.partition("=")
                result[key] = value
        return result
    except Exception:
        return {}


def _clean(value: str) -> str:
    return value.strip().strip('"').replace("_", " ").strip()


def _device_name(path: str) -> str | None:
    props = _props(path)
    if props.get("ID_BUS") == "bluetooth":
        return None
    for key in ("ID_USB_MODEL", "ID_MODEL", "ID_MODEL_ENC", "NAME"):
        value = _clean(props.get(key, ""))
        if value:
            return value
    for key in ("ID_USB_VENDOR_ENC", "ID_VENDOR_ENC", "ID_VENDOR"):
        value = _clean(props.get(key, ""))
        if value:
            return value
    return None


def run(service) -> None:
    proc = subprocess.Popen(
        ["udevadm", "monitor", "--subsystem-match=input", "--subsystem-match=usb", "--udev"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=1,
    )
    for line in proc.stdout:
        lowered = line.lower()
        action = ""
        if "bind" in lowered or ("add" in lowered and "remove" not in lowered and "unbind" not in lowered):
            action = "add"
        elif "remove" in lowered or "unbind" in lowered:
            action = "remove"
        else:
            continue
        name = _device_name(line.strip().split()[-1])
        if not name:
            continue
        service.notify("device", action=action, name=name)
    proc.terminate()