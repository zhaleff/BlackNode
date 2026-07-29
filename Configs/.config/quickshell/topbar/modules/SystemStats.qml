import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../" as Shell

RowLayout {
    id: root
    spacing: 10

    property real cpuPercent: 0
    property real tempCelsius: 0
    property real diskPercent: 0

    property var _prevIdle: 0
    property var _prevTotal: 0

    component Stat: RowLayout {
        property string glyph
        property string label
        spacing: 3
        Text {
            text: glyph
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            color: Shell.Colors.surfaceText
        }
        Text {
            text: label
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: Shell.Colors.surfaceText
        }
    }

    Stat { glyph: "\uf2db"; label: Math.round(root.cpuPercent) + "%" }      // 
    Stat { glyph: "\uf2c9"; label: Math.round(root.tempCelsius) + "°C" }    // 
    Stat { glyph: "\uf0a0"; label: Math.round(root.diskPercent) + "%" }     // 

    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
                const idle = line[3] + line[4]
                const total = line.reduce((a, b) => a + b, 0)
                const diffIdle = idle - root._prevIdle
                const diffTotal = total - root._prevTotal
                if (diffTotal > 0)
                    root.cpuPercent = 100 * (1 - diffIdle / diffTotal)
                root._prevIdle = idle
                root._prevTotal = total
            }
        }
    }

    Process {
        id: tempProc
        command: ["bash", "-lc",
            "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: root.tempCelsius = Number(text.trim()) / 1000
        }
    }

    Process {
        id: diskProc
        command: ["bash", "-lc", "df --output=pcent / | tail -1 | tr -d ' %'"]
        stdout: StdioCollector {
            onStreamFinished: root.diskPercent = Number(text.trim()) || 0
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            tempProc.running = true
            diskProc.running = true
        }
    }
}
