import shutil
import subprocess

from .emit import emit
from .pkg import HEADER_ICON, MAX_SHOWN, icon_for, order

AUR_ICON = "\U000F08C7"


def _helper():
    return shutil.which("paru") or shutil.which("yay")


def main():
    helper = _helper()
    if not helper:
        emit(AUR_ICON, cls="error", tooltip="AUR helper not found", alt="error")
        return

    out = subprocess.run([helper, "-Qua"], capture_output=True, text=True).stdout
    updates = [line for line in out.splitlines() if line.strip()]
    total = len(updates)

    if total == 0:
        emit(AUR_ICON, cls="none", tooltip="AUR up to date", alt="none")
        return

    ordered = order(updates)
    tooltip_lines = [f"{HEADER_ICON}  Pending AUR Updates: {total}", ""]
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

    emit(f"{AUR_ICON} {total}", cls=cls, tooltip="\n".join(tooltip_lines), alt=cls)


if __name__ == "__main__":
    main()