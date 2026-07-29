import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../" as Shell
import "../components" as Components

RowLayout {
    id: root
    spacing: 6

    property int pacmanCount: 0
    property int aurCount: 0

    Components.SvgIcon {
        iconName: "package"
        iconSize: 16
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: root.pacmanCount
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: Shell.Colors.surfaceText
    }
    Text {
        text: "\uf176 " + root.aurCount // 
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: Shell.Colors.primary
        visible: root.aurCount > 0
    }

    Process {
        id: pacmanCheck
        command: ["checkupdates"]
        stdout: StdioCollector {
            onStreamFinished: root.pacmanCount = text.trim().length
                ? text.trim().split("\n").length : 0
        }
    }
    Process {
        id: aurCheck
        command: ["bash", "-lc", "command -v paru >/dev/null && paru -Qua || true"]
        stdout: StdioCollector {
            onStreamFinished: root.aurCount = text.trim().length
                ? text.trim().split("\n").length : 0
        }
    }

    Timer {
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            pacmanCheck.running = true
            aurCheck.running = true
        }
    }
}
