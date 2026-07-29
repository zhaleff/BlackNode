import QtQuick
import QtQuick.Layouts
import "../" as Shell
import "../components" as Components

RowLayout {
    id: root
    spacing: 8

    property date now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Components.SvgIcon {
        iconName: "calendar-days"
        iconSize: 14
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: Qt.formatTime(root.now, "hh:mm ap").toUpperCase()
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 15
        font.weight: Font.DemiBold
        color: Shell.Colors.surfaceText
        Layout.alignment: Qt.AlignVCenter
    }
}
