import glob
import subprocess


def _sh(*args):
    return subprocess.run(list(args), capture_output=True, text=True)


def mic_apps():
    try:
        out = _sh("pactl", "list", "source-outputs").stdout
    except Exception:
        return []
    apps = []
    for line in out.splitlines():
        if "application.name" in line:
            _, _, value = line.partition("=")
            apps.append(value.strip().strip('"'))
    return apps


def cam_apps():
    apps = []
    for dev in glob.glob("/dev/video*"):
        try:
            out = _sh("fuser", dev).stdout
        except Exception:
            continue
        for pid in out.split():
            try:
                proc = _sh("ps", "-p", pid, "-o", "comm=").stdout.strip()
            except Exception:
                continue
            if proc and proc not in apps:
                apps.append(proc)
    return apps