import QtQuick

Rectangle {
    id: tab

    property string label: ""
    property int count: 0
    property bool active: false
    signal clicked()

    radius: height / 2
    height: 30
    width: content.implicitWidth + 24
    color: active ? "#3a3a3a" : "transparent"

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: tab.label
            color: tab.active ? "#ffffff" : "#9a9a9a"
            font.pixelSize: 12
            font.weight: 500
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: tab.count
            color: tab.active ? "#c9c9c9" : "#6e6e6e"
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: tab.clicked()
    }
}
