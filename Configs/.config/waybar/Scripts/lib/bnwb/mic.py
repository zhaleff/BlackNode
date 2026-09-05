from .emit import emit
from .sensors import mic_apps


def main():
    apps = mic_apps()
    if apps:
        emit("\U000F036C", cls="mic-active", tooltip="Microphone: " + ", ".join(apps))
    else:
        emit("\U000F036D", cls="idle", tooltip="Microphone idle")


if __name__ == "__main__":
    main()