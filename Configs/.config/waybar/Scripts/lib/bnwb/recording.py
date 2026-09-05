import subprocess

from .emit import emit

VIDEO_ICON = "\uF03D"


def main():
    r = subprocess.run(["pgrep", "-x", "wf-recorder"], capture_output=True, text=True)
    if r.returncode == 0:
        emit(VIDEO_ICON, cls="recording", tooltip="Recording in progress")
    else:
        emit(VIDEO_ICON, cls="idle", tooltip="Not recording")


if __name__ == "__main__":
    main()