import QtQuick
import ".." as Shell

Rectangle {
    id: root

    property string text: "View Settings"
    property string iconName: ""
    signal clicked()

    implicitHeight: 44
    radius: height / 2
    color: mouse.containsMouse
           ? Shell.Colors.primary
           : Shell.Colors.alpha(Shell.Colors.primary, 0.85)

    Behavior on color { ColorAnimation { duration: 180 } }

    scale: mouse.pressed ? 0.97 : (mouse.containsMouse ? 1.015 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.8 }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        SvgIcon {
            visible: root.iconName.length > 0
            iconName: root.iconName
            iconSize: 16
            iconColor: Shell.Colors.primaryText
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.text
            color: Shell.Colors.primaryText
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
