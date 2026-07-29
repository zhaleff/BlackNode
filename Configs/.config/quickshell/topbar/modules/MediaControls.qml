import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../" as Shell

RowLayout {
    id: root
    spacing: 6

    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0]

    IconButton {
        glyph: "\uf048" // 
        enabled: root.player?.canGoPrevious ?? false
        onClicked: root.player?.previous()
    }

    IconButton {
        glyph: root.player?.isPlaying ? "\uf04c" : "\uf04b" //  / 
        enabled: root.player?.canTogglePlaying ?? false
        onClicked: root.player?.togglePlaying()
        emphasized: true
    }

    IconButton {
        glyph: "\uf051" // 
        enabled: root.player?.canGoNext ?? false
        onClicked: root.player?.next()
    }

    component IconButton: Item {
        id: btn
        property string glyph
        property bool enabled: true
        property bool emphasized: false
        signal clicked

        Layout.preferredWidth: 22
        Layout.preferredHeight: 22

        Text {
            anchors.centerIn: parent
            text: btn.glyph
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            color: !btn.enabled ? Shell.Colors.alpha(Shell.Colors.surfaceText, 0.35)
                   : btn.emphasized ? Shell.Colors.primary
                   : Shell.Colors.surfaceText
        }

        MouseArea {
            anchors.fill: parent
            enabled: btn.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }
}
