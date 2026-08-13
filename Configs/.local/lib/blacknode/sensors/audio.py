import subprocess


def get_sink_volume(sink: str = "@DEFAULT_AUDIO_SINK@") -> tuple[int, bool]:
    out = subprocess.run(
        ["wpctl", "get-volume", sink],
        capture_output=True, text=True,
    ).stdout.strip()
    muted = "MUTED" in out
    parts = out.split()
    vol = int(float(parts[1]) * 100) if len(parts) > 1 else 0
    return vol, muted


def toggle_mute(sink: str = "@DEFAULT_AUDIO_SINK@") -> None:
    subprocess.run(
        ["wpctl", "set-mute", sink, "toggle"],
        capture_output=True,
    )
