import subprocess
import json


def get_battery() -> tuple[int | None, str | None]:
    device = _find_battery_device()
    if not device:
        return None, None
    out = subprocess.run(
        ["upower", "-i", device],
        capture_output=True, text=True,
    ).stdout
    return _parse_upower(out)


def _find_battery_device() -> str | None:
    try:
        out = subprocess.run(
            ["upower", "-e"], capture_output=True, text=True,
        ).stdout
        for line in out.splitlines():
            if "BAT" in line:
                return line.strip()
    except Exception:
        pass
    return None


def _parse_upower(output: str) -> tuple[int | None, str | None]:
    capacity = None
    state = None
    for line in output.splitlines():
        stripped = line.strip()
        if stripped.startswith("percentage"):
            try:
                capacity = int(stripped.split()[1].rstrip("%"))
            except (ValueError, IndexError):
                pass
        if stripped.startswith("state"):
            try:
                state = stripped.split()[1]
            except IndexError:
                pass
    return capacity, state
