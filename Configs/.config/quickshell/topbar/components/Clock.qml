import QtQuick

Item {
    id: root

    required property var theme

    property string text: "00:00"

    implicitWidth: label.implicitWidth + root.theme.sysPadCell * 2
    implicitHeight: root.theme.pillH

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.family: root.theme.fMono
        font.pixelSize: root.theme.fsBody
        font.weight: Font.DemiBold
        color: root.theme.paper
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            var d = new Date()
            root.text = String(d.getHours()).padStart(2, "0") + ":" + String(d.getMinutes()).padStart(2, "0")
        }
        Component.onCompleted: triggered()
    }
}
