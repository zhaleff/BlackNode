import subprocess

from .emit import emit
from .pkg import HEADER_ICON, MAX_SHOWN, icon_for, order


def main():
    try:
        out = subprocess.run(["checkupdates"], capture_output=True, text=True).stdout
    except FileNotFoundError:
        emit("", cls="none", tooltip="checkupdates not found")
        return
    updates = [line for line in out.splitlines() if line.strip()]
    total = len(updates)

    if total == 0:
        emit("", cls="none", tooltip="System is up to date")
        return

    ordered = order(updates)
    tooltip_lines = [f"{HEADER_ICON}  Pending System Updates: {total}", ""]
    for line in ordered[:MAX_SHOWN]:
        pkg = line.split(" ", 1)[0]
        rest = line.split(" ", 1)[1] if " " in line else ""
        tooltip_lines.append(f"{icon_for(pkg)}  {pkg}  {rest}")

    remaining = total - min(len(ordered), MAX_SHOWN)
    if remaining > 0:
        tooltip_lines.append(f"...and {remaining} more")

    cls = "normal"
    if total >= 30:
        cls = "critical"
    elif total >= 10:
        cls = "warning"

    emit(str(total), cls=cls, tooltip="\n".join(tooltip_lines), alt=cls)


if __name__ == "__main__":
    main()