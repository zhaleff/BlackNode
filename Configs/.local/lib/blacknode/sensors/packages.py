import subprocess


def count_updates() -> tuple[int, int]:
    official = _checkupdates()
    aur = _aur_updates()
    return official, aur


def _checkupdates() -> int:
    try:
        out = subprocess.run(
            ["checkupdates"],
            capture_output=True, text=True, timeout=30,
        )
        return len(out.stdout.strip().splitlines()) if out.stdout.strip() else 0
    except Exception:
        return 0


def _aur_updates() -> int:
    try:
        out = subprocess.run(
            ["yay", "-Qua"],
            capture_output=True, text=True, timeout=30,
        )
        return len(out.stdout.strip().splitlines()) if out.stdout.strip() else 0
    except Exception:
        return 0
