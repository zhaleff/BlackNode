from .emit import emit
from .sensors import cam_apps


def main():
    apps = cam_apps()
    if apps:
        emit("\U000F0100", cls="cam-active", tooltip="Camera: " + ", ".join(apps))
    else:
        emit("\U000F05DF", cls="idle", tooltip="Camera idle")


if __name__ == "__main__":
    main()