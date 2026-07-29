import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
import "../" as Shell
import "../components" as Components

RowLayout {
    id: root
    spacing: 14

    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property bool btOn: btAdapter ? btAdapter.enabled : false
    readonly property bool btConn: {
        if (!btAdapter || !btAdapter.enabled) return false
        var devices = btAdapter.devices
        var count = devices ? devices.count : 0
        for (var i = 0; i < count; i++) {
            var d = devices.values[i]
            if (d && d.connected) return true
        }
        return false
    }

    readonly property bool wifiOn: {
        var devs = Networking.devices
        var count = devs ? devs.count : 0
        for (var i = 0; i < count; i++) {
            var d = devs.values[i]
            if (d && d.type === DeviceType.Wifi) return d.connected
        }
        return false
    }

    readonly property var batDev: UPower.displayDevice
    readonly property real batPct: batDev ? batDev.percentage : -1
    readonly property bool batChg: batDev ? (batDev.state === UPowerDeviceState.Charging || batDev.state === UPowerDeviceState.FullyCharged) : false
    readonly property bool batPresent: batDev ? batDev.isPresent : false

    Components.SvgIcon {
        iconName: btIcon(root.btOn, root.btConn)
        iconSize: 18
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["bluetoothctl", "menu"])
        }
    }

    Components.SvgIcon {
        iconName: "bell"
        iconSize: 18
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["dunstctl", "history"])
        }
    }

    Components.SvgIcon {
        iconName: wifiOn ? "wifi" : "wifi-off"
        iconSize: 18
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["nm-connection-editor"])
        }
    }

    Components.SvgIcon {
        iconName: batIcon(root.batPct, root.batChg, root.batPresent)
        iconSize: 18
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["gnome-power-statistics"])
        }
    }

    function btIcon(on, conn) {
        if (!on) return "bluetooth-off"
        if (conn) return "bluetooth-connected"
        return "bluetooth"
    }

    function batIcon(pct, charging, present) {
        if (!present) return "battery-off"
        if (charging) return "battery-charging"
        if (pct >= 75) return "battery-full"
        if (pct >= 40) return "battery-medium"
        if (pct >= 15) return "battery-low"
        return "battery-warning"
    }
}
