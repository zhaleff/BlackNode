import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../" as Shell
import "../components" as Components

RowLayout {
    id: root
    spacing: 6

    property real tempF: 0

    Components.SvgIcon {
        iconName: "weather"
        iconSize: 18
        anchors.verticalCenter: parent.verticalCenter
    }
    Text {
        text: Math.round(root.tempF) + "°F"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        font.weight: Font.DemiBold
        color: Shell.Colors.surfaceText
    }

    Process {
        id: weatherProc
        command: ["bash", "-lc", "curl -sf 'wttr.in/?format=%t' | tr -dc '0-9-'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = Number(text.trim())
                if (!Number.isNaN(v)) root.tempF = v
            }
        }
    }

    Timer {
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: weatherProc.running = true
    }
}
