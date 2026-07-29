import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../" as Shell
import "../components" as Components

RowLayout {
    id: root
    spacing: 16

    property int workspaceCount: 5

    Repeater {
        model: root.workspaceCount

        delegate: Rectangle {
            id: wsButton
            required property int index
            readonly property int wsId: index + 1
            readonly property bool active: Hyprland.focusedWorkspace?.id === wsId

            Layout.preferredWidth: active ? 30 : 20
            Layout.preferredHeight: 20
            radius: 12
            color: active ? Shell.Colors.primary
                   : mouseArea.containsMouse ? Shell.Colors.primary
                                              : Shell.Colors.alpha(Shell.Colors.outline, 0.2)

            Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic } }
            Behavior on Layout.preferredWidth { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            Behavior on radius { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

            Components.SvgIcon {
                anchors.centerIn: parent
                iconName: active ? "squirrel" : "circle-dot"
                iconSize: active ? 16 : 10
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch(`workspace ${wsButton.wsId}`)
            }
        }
    }
}
