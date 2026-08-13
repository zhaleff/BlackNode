import subprocess


def device_name_from_path(path: str) -> str:
    try:
        props = subprocess.run(
            ["udevadm", "info", "--query=property", f"--path={path}"],
            capture_output=True, text=True, timeout=5,
        ).stdout
        for line in props.splitlines():
            if line.startswith("ID_MODEL=") or line.startswith("NAME="):
                val = line.split("=", 1)[1].strip('"').replace("_", " ")
                if val:
                    return val
    except Exception:
        pass
    return "Unknown device"


def monitor_events():
    proc = subprocess.Popen(
        ["udevadm", "monitor", "--subsystem-match=input",
         "--subsystem-match=usb", "--udev"],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
        text=True, bufsize=1,
    )
    return proc
