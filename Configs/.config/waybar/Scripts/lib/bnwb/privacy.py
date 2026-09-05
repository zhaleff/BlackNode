from .emit import emit
from .sensors import cam_apps, mic_apps


def main():
    mics = mic_apps()
    cams = cam_apps()

    if mics and cams:
        tooltip = (
            "Microphone: " + ", ".join(mics)
            + "\nCamera: " + ", ".join(cams)
        )
        emit("\U000F036C \U000F0100", cls="active", tooltip=tooltip)
    elif mics:
        emit("\U000F036C \U000F0104", cls="mic-active",
             tooltip="Microphone: " + ", ".join(mics))
    elif cams:
        emit("\U000F036D \U000F0100", cls="cam-active",
             tooltip="Camera: " + ", ".join(cams))
    else:
        emit("\U000F036D \U000F0104", cls="idle",
             tooltip="Microphone and camera idle")


if __name__ == "__main__":
    main()