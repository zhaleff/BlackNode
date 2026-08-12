import QtQuick
import "../" as Root

Item {
    id: root

    property var lyricsLines: []
    property int currentIndex: -1
    property real currentLineProgress: 0
    property bool loading: false
    property bool available: false

    implicitWidth: 320

    Text {
        anchors.centerIn: parent
        visible: root.loading
        text: "Loading lyrics…"
        color: Root.Theme.textMuted
        font.pixelSize: 13
        font.family: Root.Theme.fontFamily
    }

    Text {
        anchors.centerIn: parent
        visible: !root.loading && !root.available
        text: "No lyrics found"
        color: Root.Theme.textMuted
        font.pixelSize: 13
        font.family: Root.Theme.fontFamily
    }

    ListView {
        id: list
        anchors.fill: parent
        visible: !root.loading && root.available
        model: root.lyricsLines
        interactive: false
        clip: true
        highlightMoveDuration: 320
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: height / 2 - 14
        preferredHighlightEnd: height / 2 + 14
        currentIndex: root.currentIndex

        delegate: Item {
            width: list.width
            height: 34

            readonly property int distance: Math.abs(index - root.currentIndex)
            readonly property bool isCurrent: index === root.currentIndex

            Item {
                anchors.centerIn: parent
                width: parent.width
                height: label.implicitHeight
                clip: isCurrent

                Text {
                    id: label
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData.text.length > 0 ? modelData.text : "♪"
                    color: isCurrent ? Root.Theme.text : Root.Theme.textMuted
                    font.pixelSize: isCurrent ? 15 : 13
                    font.bold: isCurrent
                    font.family: Root.Theme.fontFamily
                    opacity: distance === 0 ? 1.0 : (distance === 1 ? 0.45 : 0.18)
                    scale: isCurrent ? 1.0 : 0.94
                    elide: Text.ElideNone
                    wrapMode: Text.NoWrap

                    Behavior on opacity {
                        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 240 }
                    }
                }

                Rectangle {
                    visible: isCurrent
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * (1 - root.currentLineProgress)
                    x: parent.width - width
                    color: Root.Theme.surface

                    Behavior on width {
                        NumberAnimation { duration: 180; easing.type: Easing.Linear }
                    }
                }
            }
        }
    }
}
