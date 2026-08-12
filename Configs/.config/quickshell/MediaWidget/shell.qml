import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

ShellRoot {
    id: shellRoot

    PanelWindow {
        id: panelWindow
        visible: false

        anchors {
            top: true
        }
        margins {
            top: 56
        }

        implicitWidth: 720
        implicitHeight: 320
        color: "transparent"

        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        MediaPanel {
            anchors.fill: parent
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: mouse.accepted = false
        }
    }

    IpcHandler {
        target: "mediaPanel"

        function toggle(): void {
            panelWindow.visible = !panelWindow.visible
        }

        function show(): void {
            panelWindow.visible = true
        }

        function hide(): void {
            panelWindow.visible = false
        }
    }
}
