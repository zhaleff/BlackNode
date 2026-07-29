import QtQuick
import ".." as Shell

Item {
    id: root

    property string iconName: ""
    property int iconSize: 20
    property color iconColor: Shell.Colors.icon
    property url iconSource: Qt.resolvedUrl("../assets/" + iconName + ".svg")

    width: iconSize
    height: iconSize

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: root.iconSource
        smooth: true
    }
}
