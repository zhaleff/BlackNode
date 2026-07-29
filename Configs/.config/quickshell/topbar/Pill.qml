import QtQuick
import QtQuick.Layouts
import "." as Shell

// hey, I DONT KNOW
Item {
    id: root

    property alias content: inner.children
    property bool hoverable: true
    property bool showBackground: true
    property real hPad: 12
    property real vPad: 12
    default property alias data: inner.children

    implicitWidth: inner.implicitWidth + hPad * 2
    implicitHeight: inner.implicitHeight + vPad * 2

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: height / 2
        color: showBackground ? (hoverArea.containsMouse
               ? Shell.Colors.alpha(Shell.Colors.secondaryContainer, 0.5)
               : Shell.Colors.alpha(Shell.Colors.outline, 0.12)) : "transparent"

        Behavior on color {
            ColorAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: root.hoverable
        acceptedButtons: Qt.NoButton
    }

    RowLayout {
        id: inner
        anchors.centerIn: parent
        spacing: 8
    }
}
