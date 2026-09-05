import subprocess
import sys

from .emit import emit

DND_ON = "\U000F009B"
DND_OFF = "\U000F009A"


def is_paused():
    out = subprocess.run(["dunstctl", "is-paused"], capture_output=True, text=True).stdout
    return "true" in out


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "toggle":
        subprocess.run(["dunstctl", "set-paused", "toggle"])
        return
    if is_paused():
        emit(DND_ON, cls="dnd-active", tooltip="Do Not Disturb: On")
    else:
        emit(DND_OFF, cls="dnd-inactive", tooltip="Do Not Disturb: Off")


if __name__ == "__main__":
    main()