import QtQuick
import "../" as Root

Item {
    id: root

    property real positionMs: 0
    property real lengthMs: 1
    property bool playing: false

    readonly property real fraction: lengthMs > 0 ? Math.min(1, positionMs / lengthMs) : 0

    implicitHeight: 20

    property real phase: 0

    NumberAnimation on phase {
        running: root.playing
        loops: Animation.Infinite
        from: 0
        to: Math.PI * 2
        duration: 1400
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        readonly property real amplitude: root.playing ? 3.2 : 0
        readonly property real wavelength: 14
        readonly property real trackThickness: 4

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var midY = height / 2
            var w = width
            var fillEnd = w * root.fraction

            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            ctx.strokeStyle = Root.Theme.outline
            ctx.lineWidth = trackThickness
            ctx.beginPath()
            ctx.moveTo(fillEnd + 6, midY)
            ctx.lineTo(w, midY)
            ctx.stroke()

            ctx.strokeStyle = Root.Theme.primary
            ctx.lineWidth = trackThickness
            ctx.beginPath()
            var started = false
            for (var x = 0; x <= fillEnd; x += 2) {
                var y = midY + Math.sin((x / wavelength) + root.phase) * amplitude
                if (!started) {
                    ctx.moveTo(x, y)
                    started = true
                } else {
                    ctx.lineTo(x, y)
                }
            }
            ctx.stroke()

            if (fillEnd > 0) {
                ctx.fillStyle = Root.Theme.primary
                ctx.beginPath()
                var headY = midY + Math.sin((fillEnd / wavelength) + root.phase) * amplitude
                ctx.arc(fillEnd, headY, trackThickness * 0.9, 0, Math.PI * 2)
                ctx.fill()
            }
        }

        Connections {
            target: root
            function onFractionChanged() { canvas.requestPaint() }
            function onPhaseChanged() { canvas.requestPaint() }
            function onPlayingChanged() { canvas.requestPaint() }
        }
    }
}
