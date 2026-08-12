import QtQuick
import QtQuick.Layouts
import "../" as Root

Item {
    id: root

    property bool playing: false
    property bool shuffleActive: false
    property bool repeatActive: false
    property bool canGoNext: true
    property bool canGoPrevious: true

    signal playPauseRequested()
    signal nextRequested()
    signal previousRequested()
    signal shuffleRequested()
    signal repeatRequested()

    implicitHeight: 64
    implicitWidth: row.implicitWidth

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Root.Theme.spacingSmall

        component IconButton: Rectangle {
            id: btn
            property string glyph: ""
            property bool prominent: false
            property bool active: false
            property bool enabledState: true
            signal clicked()

            width: prominent ? 52 : 40
            height: width
            radius: Root.Theme.radiusButton
            color: {
                if (prominent) return Root.Theme.primary
                if (active) return Qt.rgba(Root.Theme.primary.r, Root.Theme.primary.g, Root.Theme.primary.b, 0.18)
                return "transparent"
            }
            opacity: enabledState ? 1.0 : 0.35

            Behavior on color {
                ColorAnimation { duration: 160 }
            }
            Behavior on scale {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }

            Text {
                anchors.centerIn: parent
                text: btn.glyph
                font.pixelSize: btn.prominent ? 20 : 15
                color: btn.prominent ? Root.Theme.accentText
                                      : (btn.active ? Root.Theme.primary : Root.Theme.text)
            }

            MouseArea {
                anchors.fill: parent
                enabled: btn.enabledState
                cursorShape: Qt.PointingHandCursor
                onPressed: btn.scale = 0.9
                onReleased: btn.scale = 1.0
                onCanceled: btn.scale = 1.0
                onClicked: btn.clicked()
            }
        }

        IconButton {
            glyph: "\uf074"
            active: root.shuffleActive
            onClicked: root.shuffleRequested()
        }

        IconButton {
            glyph: "\uf048"
            enabledState: root.canGoPrevious
            onClicked: root.previousRequested()
        }

        IconButton {
            prominent: true
            glyph: root.playing ? "\uf04c" : "\uf04b"
            onClicked: root.playPauseRequested()
        }

        IconButton {
            glyph: "\uf051"
            enabledState: root.canGoNext
            onClicked: root.nextRequested()
        }

        IconButton {
            glyph: "\uf021"
            active: root.repeatActive
            onClicked: root.repeatRequested()
        }
    }
}
