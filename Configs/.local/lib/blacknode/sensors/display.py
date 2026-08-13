import subprocess


def get_brightness() -> int:
    out = subprocess.run(
        ["brightnessctl", "info"],
        capture_output=True, text=True,
    ).stdout
    for line in out.splitlines():
        if "%" in line:
            try:
                return int(line.split("(")[-1].split("%")[0])
            except (IndexError, ValueError):
                pass
    return 0
