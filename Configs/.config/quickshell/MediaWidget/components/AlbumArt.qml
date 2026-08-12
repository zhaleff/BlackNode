import QtQuick
import "../" as Root

Item {
    id: root

    property string artSource: ""
    property int artSize: 220

    implicitWidth: artSize
    implicitHeight: artSize + 48

    Rectangle {
        id: frame
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 24
        width: artSize
        height: artSize
        radius: Root.Theme.radiusArt
        color: Root.Theme.surfaceVariant
        clip: true

        Image {
            id: art
            anchors.fill: parent
            source: root.artSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready

            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: art.status !== Image.Ready
            text: "\uf001"
            font.pixelSize: 42
            color: Root.Theme.textMuted
        }

        Behavior on radius {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }
}
