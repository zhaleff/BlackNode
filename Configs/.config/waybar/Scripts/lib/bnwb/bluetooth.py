import re
import subprocess

from .emit import emit


def _bt(*args):
    return subprocess.run(["bluetoothctl", *args], capture_output=True, text=True)


def device_icon(icon_type):
    icon_type = icon_type or ""
    groups = (
        (("audio-card", "audio-headset", "audio-headphones"), "\U000F02CB"),
        (("input-mouse",), "\U000F037D"),
        (("input-keyboard",), "\U000F030C"),
        (("input-gaming",), "\U000F02B4"),
        (("phone",), "\U000F011C"),
        (("computer",), "\U000F01C5"),
    )
    for prefixes, icon in groups:
        if icon_type.startswith(prefixes):
            return icon
    return "\U000F09A2"


def is_powered():
    return "Powered: yes" in _bt("show").stdout


def main():
    if not is_powered():
        emit("\U000F00B2", cls="off", tooltip="Bluetooth is off", alt="off")
        return

    connected = []
    for line in _bt("devices", "Connected").stdout.splitlines():
        parts = line.split()
        if len(parts) >= 3:
            connected.append((parts[1], " ".join(parts[2:])))

    if not connected:
        emit("\U000F00AF", cls="on",
             tooltip="Bluetooth is on\nNo devices connected", alt="on")
        return

    lines = ["Connected"]
    for mac, name in connected:
        info = _bt("info", mac).stdout
        battery = None
        for line in info.splitlines():
            if "Battery Percentage" in line:
                m = re.search(r"\((\d+)\)", line)
                if m:
                    battery = m.group(1)
        icon_type = ""
        for line in info.splitlines():
            if line.startswith("Icon:"):
                icon_type = line.split(":", 1)[1].strip()
        label = f"{device_icon(icon_type)} {name}"
        if battery:
            label += f" \u2014 {battery}%"
        lines.append(label)

    text = "\U000F00B1"
    if len(connected) > 1:
        text += f" {len(connected)}"

    emit(text, cls="connected", tooltip="\n".join(lines), alt="connected")


if __name__ == "__main__":
    main()