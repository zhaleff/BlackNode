import QtQuick
import Quickshell
import qs.services.clipboard
import qs.widgets.clipboard

ShellRoot {
    Scope {
        Variants {
            model: Quickshell.screens

            Item {
                required property var modelData

                PanelWindow {
                    id: win
                    implicitWidth: Screen.width
                    implicitHeight: 320
                    color: "transparent"
                    anchors.top: true
                    anchors.left: true
                    anchors.right: true
                    exclusiveZone: 0

                    MouseArea {
                        id: topSensor
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 4
                        hoverEnabled: true
                        z: 100
                        onEntered: panel.show()
                    }

                    ClipboardPanel {
                        id: panel
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 12
                    }
                }
            }
        }
    }
}
