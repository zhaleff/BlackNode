import os
import re
import shutil
import subprocess

from .emit import emit

DISTRO_ICONS = {
    "nixos": "\uE843",
    "arch": "\uF303",
    "artix": "\uF31F",
    "manjaro": "\uF312",
    "endeavouros": "\uF322",
    "cachyos": "\uF385",
}
GENERIC_ICON = "\uF17C"

ICON_HOST = "\U000F01C5"
ICON_KERNEL = "\U000F08C7"
ICON_UPTIME = "\U000F0150"
ICON_PACKAGES = "\U000F03D7"
ICON_CPU = "\uF4BC"
ICON_GPU = "\U000F08AE"
ICON_MEMORY = "\U000F035B"


def _uptime():
    try:
        s = float(open("/proc/uptime").read().split()[0])
    except (OSError, ValueError):
        return "?"
    d, r = divmod(int(s), 86400)
    h, m = divmod(r, 3600)
    m //= 60
    if d:
        return f"{d}d {h}h {m}m"
    if h:
        return f"{h}h {m}m"
    return f"{m}m"


def _cpu():
    try:
        with open("/proc/cpuinfo") as f:
            for line in f:
                if line.startswith("model name"):
                    name = line.split(":", 1)[1].strip()
                    return re.sub(r"\s+", " ",
                                  name.replace("(R)", "").replace("(TM)", ""))
    except OSError:
        pass
    return "?"


def _gpu():
    try:
        out = subprocess.run(["lspci", "-nn"], capture_output=True, text=True).stdout
    except FileNotFoundError:
        return "?"
    for line in out.splitlines():
        if "VGA" in line or "3D" in line or "Display" in line:
            desc = line.split(": ", 1)[1] if ": " in line else line
            return re.sub(r"\s+", " ", desc.split(" [")[0])
    return "?"


def _mem():
    try:
        out = subprocess.run(["free", "-h"], capture_output=True, text=True).stdout
    except FileNotFoundError:
        return "?"
    for line in out.splitlines():
        if line.startswith("Mem:"):
            parts = line.split()
            if len(parts) >= 3:
                return f"{parts[2]}/{parts[1]}"
    return "?"


def _packages():
    try:
        out = subprocess.run(["pacman", "-Qq"], capture_output=True, text=True).stdout
    except FileNotFoundError:
        return "?"
    pac = len([l for l in out.splitlines() if l.strip()])
    aur = ""
    for helper in ("paru", "yay"):
        if shutil.which(helper):
            m = subprocess.run([helper, "-Qm"], capture_output=True, text=True).stdout
            c = len([l for l in m.splitlines() if l.strip()])
            if c:
                aur = f" \u00b7 {c} AUR"
            break
    return f"{pac}{aur}"


def main():
    release = {}
    try:
        with open("/etc/os-release") as f:
            for line in f:
                if "=" in line:
                    key, _, value = line.strip().partition("=")
                    release[key] = value.strip('"')
    except OSError:
        pass

    distro_id = release.get("ID", "")
    name = release.get("NAME", "")
    icon = DISTRO_ICONS.get(distro_id, GENERIC_ICON)

    tooltip = "\n".join([
        f"{icon}  {name}",
        f"{ICON_HOST}  {os.uname().nodename}",
        f"{ICON_KERNEL}  {os.uname().release}",
        f"{ICON_UPTIME}  {_uptime()}",
        f"{ICON_PACKAGES}  {_packages()}",
        f"{ICON_CPU}  {_cpu()}",
        f"{ICON_GPU}  {_gpu()}",
        f"{ICON_MEMORY}  {_mem()}",
    ])
    emit(icon, tooltip=tooltip)


if __name__ == "__main__":
    main()