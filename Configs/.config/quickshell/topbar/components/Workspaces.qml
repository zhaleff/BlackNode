import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var theme
    required property var hypr
    required property var wsMap

    property var wsNames: ["1", "2", "3", "4", "5"]

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        spacing: root.theme.wsSpacing
        Layout.alignment: Qt.AlignVCenter

        Repeater {
            model: root.wsNames

            delegate: Item {
                required property string modelData
                readonly property var ws: root.wsMap[modelData]
                readonly property bool active: ws ? ws.focused : false
                readonly property bool isLast: index === root.wsNames.length - 1

                implicitWidth: Math.max(root.theme.wsMinCell, txt.implicitWidth + root.theme.wsPadCell * 2)
                implicitHeight: root.theme.pillH

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.theme.wsIndicatorWidth
                    height: parent.height * root.theme.wsIndicatorHeight
                    color: root.theme.accent
                    visible: active
                }

                Text {
                    id: txt
                    anchors.centerIn: parent
                    text: modelData
                    font.family: root.theme.fBody
                    font.pixelSize: root.theme.fsBody
                    font.weight: active ? Font.DemiBold : Font.Normal
                    color: active ? root.theme.paper : root.theme.mute
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.theme.wsSeparatorWidth
                    height: parent.height * root.theme.wsSeparatorHeight
                    color: root.theme.line
                    visible: !isLast
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.hypr.dispatch("workspace " + modelData)
                }
            }
        }
    }
}
