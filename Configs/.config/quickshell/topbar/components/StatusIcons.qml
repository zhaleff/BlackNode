import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var theme
    required property bool btOn
    required property bool btConn
    required property bool wifiOn
    required property bool batPresent
    required property real batPct
    required property bool batChg
    required property bool batCrit

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        spacing: root.theme.sysSpacing
        Layout.alignment: Qt.AlignVCenter

        Clock {
            id: clockComp
            theme: root.theme
        }

        Item {
            implicitWidth: root.theme.sysSeparatorWidth
            implicitHeight: root.theme.pillH
            Layout.maximumWidth: root.theme.sysSeparatorWidth

            Rectangle {
                anchors.centerIn: parent
                width: root.theme.sysSeparatorWidth
                height: parent.height * root.theme.sysSeparatorHeight
                color: root.theme.line
            }
        }

        Item {
            implicitWidth: root.theme.sysIconSize + root.theme.sysPadCell * 2
            implicitHeight: root.theme.pillH

            Text {
                anchors.centerIn: parent
                text: root.wifiOn ? "\uF1EB" : "\uFAA8"
                font.family: root.theme.fIcons
                font.pixelSize: root.theme.sysIconSize
                color: root.wifiOn ? root.theme.paper : root.theme.mute
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: root.theme.sysSeparatorWidth
                height: parent.height * root.theme.sysSeparatorHeight
                color: root.theme.line
            }
        }

        Item {
            implicitWidth: root.theme.sysIconSize + root.theme.sysPadCell * 2
            implicitHeight: root.theme.pillH

            Text {
                anchors.centerIn: parent
                text: root.btIcon(root.btOn, root.btConn)
                font.family: root.theme.fIcons
                font.pixelSize: root.theme.sysIconSize
                color: root.btConn ? root.theme.paper : (root.btOn ? root.theme.mute : root.theme.line)
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: root.theme.sysSeparatorWidth
                height: parent.height * root.theme.sysSeparatorHeight
                color: root.theme.line
            }
        }

        Item {
            id: batCell
            implicitWidth: batIcon.implicitWidth + batPct.implicitWidth + root.theme.sysPadCell * 2
            implicitHeight: root.theme.pillH

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: parent.height * 0.6
                color: root.theme.accent
                visible: root.batCrit
            }

            Text {
                id: batIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: root.theme.sysPadCell
                text: root.batIcon()
                font.family: root.theme.fIcons
                font.pixelSize: root.theme.sysIconSize
                color: root.batCrit ? root.theme.accent : root.theme.paper
            }

            Text {
                id: batPct
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: batIcon.right
                anchors.leftMargin: 4
                text: root.batPresent ? Math.round(root.batPct) + "%" : ""
                font.family: root.theme.fMono
                font.pixelSize: root.theme.fsLabel
                font.weight: Font.DemiBold
                color: root.batCrit ? root.theme.accent : root.theme.mute
                visible: root.batPresent
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: root.theme.sysSeparatorWidth
                height: parent.height * root.theme.sysSeparatorHeight
                color: root.theme.line
            }
        }

        Item {
            implicitWidth: root.theme.sysIconSize + root.theme.sysPadCell * 2
            implicitHeight: root.theme.pillH

            Text {
                anchors.centerIn: parent
                text: "\uF011"
                font.family: root.theme.fIcons
                font.pixelSize: root.theme.sysIconSize
                color: root.theme.muteDim
            }
        }
    }

    function btIcon(on, conn) {
        if (!on) return "\uF5B2"
        if (conn) return "\uF5B0"
        return "\uF5AF"
    }

    function batIcon() {
        if (!root.batPresent) return "\uF244"
        if (root.batChg) return "\uF0E7"
        if (root.batPct >= 90) return "\uF244"
        if (root.batPct >= 65) return "\uF243"
        if (root.batPct >= 40) return "\uF242"
        if (root.batPct >= 15) return "\uF241"
        return "\uF240"
    }
}
