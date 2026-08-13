import subprocess
import re


def get_wifi_state() -> tuple[str, str, int]:
    iface = _default_interface()
    if not iface:
        return "down", "", 0
    operstate = _operstate(iface)
    ssid, signal = _link_info(iface)
    return operstate, ssid, signal


def _default_interface() -> str | None:
    out = subprocess.run(
        ["ip", "route"], capture_output=True, text=True,
    ).stdout
    for line in out.splitlines():
        if line.startswith("default"):
            parts = line.split()
            if len(parts) > 4:
                return parts[4]
    return None


def _operstate(iface: str) -> str:
    try:
        out = subprocess.run(
            ["ip", "link", "show", iface],
            capture_output=True, text=True,
        ).stdout
        return "up" if "state UP" in out or "state UNKNOWN" in out else "down"
    except Exception:
        return "down"


def _link_info(iface: str) -> tuple[str, int]:
    ssid, signal = "", 0
    try:
        link = subprocess.run(
            ["iw", "dev", iface, "link"],
            capture_output=True, text=True,
        ).stdout
        m = re.search(r"SSID:\s*(.+)", link)
        if m:
            ssid = m.group(1).strip()
        m = re.search(r"signal:\s*(-?\d+)", link)
        if m:
            signal = int(m.group(1))
    except Exception:
        pass
    return ssid, signal
