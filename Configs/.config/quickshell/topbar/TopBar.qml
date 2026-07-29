import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland._Ipc
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
import "components"

PanelWindow {
    id: root

    anchors.top: true
    anchors.left: true
    anchors.right: true
    height: theme.barH
    exclusiveZone: theme.barH
    color: "transparent"

    readonly property var theme: Theme {}

    property var hypr: Hyprland
    property var activeTop: hypr.activeToplevel
    property var wsMap: ({})

    property bool btOn: false
    property bool btConn: false
    property bool wifiOn: false
    property var batDev: UPower.displayDevice
    property real batPct: batDev ? batDev.percentage : -1
    property bool batChg: batDev ? (batDev.state === UPowerDeviceState.Charging || batDev.state === UPowerDeviceState.FullyCharged) : false
    property bool batPresent: batDev ? batDev.isPresent : false
    property bool batCrit: batPresent && batPct >= 0 && batPct < 15

    property string appName: {
        var t = root.activeTop
        if (!t) return "Desktop"
        var o = t.lastIpcObject
        if (o && o.class) return o.class
        if (t.title) return t.title.split(" \u2014 ")[0].trim() || t.title
        return "Desktop"
    }

    function rebuildWsMap() {
        var m = {}
        try {
            var list = hypr.workspaces
            var n = list ? list.count : 0
            for (var i = 0; i < n; i++) {
                var ws = list.values[i]
                if (ws) m[ws.id] = ws
            }
        } catch (e) {}
        root.wsMap = m
    }

    function refreshDevices() {
        var a = Bluetooth.defaultAdapter
        root.btOn = a ? a.enabled : false
        root.btConn = false
        if (root.btOn && a) {
            try {
                var n = a.devices ? a.devices.count : 0
                for (var i = 0; i < n; i++) {
                    var d = a.devices.values[i]
                    if (d && d.connected) { root.btConn = true; break }
                }
            } catch (e) {}
        }
        root.wifiOn = false
        try {
            var devs = Networking.devices
            var dn = devs ? devs.count : 0
            for (var j = 0; j < dn; j++) {
                var dd = devs.values[j]
                if (dd && dd.type === DeviceType.Wifi) { root.wifiOn = dd.connected; break }
            }
        } catch (e) {}
    }

    Connections { target: hypr; function onRawEvent(e) { var n = e.name; if (n && (n.indexOf("workspace") >= 0 || n.indexOf("focusedmon") >= 0 || n.indexOf("toplevel") >= 0 || n.indexOf("activewindow") >= 0)) root.rebuildWsMap() } }
    Timer { interval: 300; running: true; repeat: false; onTriggered: root.rebuildWsMap() }
    Timer { running: true; repeat: true; interval: 3000; onTriggered: root.refreshDevices(); Component.onCompleted: root.refreshDevices() }

    Rectangle {
        id: wsPill
        anchors.left: parent.left
        anchors.leftMargin: theme.topbarMarginH
        anchors.verticalCenter: parent.verticalCenter
        height: theme.pillH
        width: wsContent.implicitWidth + theme.wsPadPill * 2
        radius: theme.radiusHair
        color: theme.panel

        Workspaces {
            id: wsContent
            anchors.left: parent.left
            anchors.leftMargin: theme.wsPadPill
            anchors.verticalCenter: parent.verticalCenter
            theme: root.theme
            hypr: root.hypr
            wsMap: root.wsMap
        }
    }

    Rectangle {
        id: titlePill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: theme.pillH
        width: Math.min(titleLabel.implicitWidth + theme.titlePadH * 2, theme.titleMaxW)
        radius: theme.radiusHair
        color: theme.panel

        Text {
            id: titleLabel
            anchors.centerIn: parent
            text: root.appName
            font.family: theme.fBody
            font.pixelSize: theme.fsTitle
            font.weight: Font.DemiBold
            color: theme.paper
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    Rectangle {
        id: sysPill
        anchors.right: parent.right
        anchors.rightMargin: theme.topbarMarginH
        anchors.verticalCenter: parent.verticalCenter
        height: theme.pillH
        width: sysContent.implicitWidth + theme.sysPadPill * 2
        radius: theme.radiusHair
        color: theme.panel

        StatusIcons {
            id: sysContent
            anchors.left: parent.left
            anchors.leftMargin: theme.sysPadPill
            anchors.verticalCenter: parent.verticalCenter
            theme: root.theme
            btOn: root.btOn
            btConn: root.btConn
            wifiOn: root.wifiOn
            batPresent: root.batPresent
            batPct: root.batPct
            batChg: root.batChg
            batCrit: root.batCrit
        }
    }
}
