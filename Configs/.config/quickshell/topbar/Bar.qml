import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "." as Shell
import "modules" as Modules
import "components" as Components

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 64
    margins {
        top: 5
        left: 8
        right: 8
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: implicitHeight + margins.top

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: height / 2
        color: Shell.Colors.surface

        RowLayout {
            id: content
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 22

            Shell.Pill {
                Modules.Workspaces {}
            }

            Shell.Pill {
                Modules.PackageUpdates {}
            }

            Item { Layout.fillWidth: true }

            Item { Layout.fillWidth: true }
            Modules.ClockWidget {
                Layout.alignment: Qt.AlignVCenter
            }
            Shell.Pill {
                Modules.QuickToggles {}
            }
            Shell.Pill {
                Modules.WeatherWidget {}
            }

            Components.SvgIcon {
                iconName: "power"
                iconSize: 18
                iconColor: Shell.Colors.icon
                Layout.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["wlogout"])
                }
            }
        }
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height

        RowLayout {
            anchors.centerIn: parent
            anchors.margins: 0
            spacing: 6

            Components.SvgIcon {
                iconName: "monitor"
                iconSize: 16
                iconColor: Shell.Colors.icon
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: (function() {
                    var t = Hyprland.activeToplevel
                    if (!t) return "Desktop"
                    var o = t.lastIpcObject
                    var title = "Desktop"
                    if (o && o.class) title = o.class
                    else if (t.title) title = t.title.split(" \u2014 ")[0].trim() || t.title
                    var words = title.split(/\s+/)
                    if (words.length <= 12) return title
                    return words.slice(0, 12).join(" ") + "…"
                })()
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                color: "#000000"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                maximumLineCount: 1
                Layout.alignment: Qt.AlignVCenter
                height: parent.height
            }
        }
    }
}
