import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FloatingWindow {
  id: root
  title: "Dashboard"
  color: "transparent"
  implicitWidth: 820
  implicitHeight: 680

  // ── M3 Colors ──────────────────────────────────────────────────
  readonly property color surface:           "#0D1117"
  readonly property color surfaceCard:       "#1A1C22"
  readonly property color surfaceHover:      "#252830"
  readonly property color surfaceDim:        "#070B0F"
  readonly property color primary:           "#52A3DC"
  readonly property color textPrimary:       "#CED1E3"
  readonly property color textSecondary:     "#9FA4B9"
  readonly property color textDim:           "#636776"
  readonly property color error:             "#F2B8B5"
  readonly property color success:           "#69F0AE"
  readonly property color warning:           "#FFB940"
  readonly property color accent:            "#4EC5D4"
  readonly property string fontUI:           "DM Sans"
  readonly property string fontMono:         "JetBrains Mono"

  // ── State ─────────────────────────────────────────────────────
  property string bigTime: ""
  property string bigDate: ""

  property var gitData: null
  property var gitLangs: []
  property real gitLangTotal: 0
  property string gitStatus: "loading"

  property var sysData: null
  property var sysApps: []
  property string sysStatus: "loading"

  property var actEvents: []
  property string actStatus: "loading"

  // ── Main surface ──────────────────────────────────────────────
  Rectangle {
    anchors.fill: parent
    color: surface
    radius: 24
    clip: true
    border.color: "#1f2019"
    border.width: 1

    Flickable {
      id: flick
      anchors.fill: parent
      contentHeight: col.height + 40
      clip: true
      boundsBehavior: Flickable.OvershootBounds

      ColumnLayout {
        id: col
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        spacing: 16

        // ══════════════════  HEADER  ═══════════════════════════
        Rectangle {
          Layout.fillWidth: true
          height: 96
          color: surfaceCard
          radius: 16
          scale: 1.0
          Behavior on scale { SpringAnimation { spring: 4; damping: 0.8 } }

          RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Rectangle {
              width: 52; height: 52; radius: 26; color: primary
              Text {
                anchors.centerIn: parent
                text: "Z"
                font.pixelSize: 22; font.weight: Font.Bold
                color: "#00174D"; font.family: fontUI
              }
            }

            ColumnLayout {
              spacing: 2
              Text {
                text: "zhaleff"
                font.pixelSize: 18; font.weight: Font.Bold
                color: textPrimary; font.family: fontUI
              }
              Text {
                text: sysData ? sysData.hostname : "blacknode"
                font.pixelSize: 13; color: textSecondary; font.family: fontUI
              }
              Text {
                text: sysData ? ("Uptime: " + sysData.uptime) : ""
                font.pixelSize: 11; color: textDim; font.family: fontMono
              }
            }

            Item { Layout.fillWidth: true }

            ColumnLayout {
              spacing: 0
              Text {
                text: bigTime
                font.pixelSize: 32; font.weight: Font.Light
                color: primary; font.family: fontMono
                Layout.alignment: Qt.AlignRight
              }
              Text {
                text: bigDate
                font.pixelSize: 12; color: textSecondary; font.family: fontUI
                Layout.alignment: Qt.AlignRight
              }
            }
          }

          MouseArea {
            anchors.fill: parent; hoverEnabled: true
            onEntered: parent.scale = 1.01
            onExited: parent.scale = 1.0
          }
        }

        // ══════════════════  TWO-COLUMN GRID  ═════════════════
        RowLayout {
          Layout.fillWidth: true
          spacing: 16

          // ── GIT CARD ─────────────────────────────────────────
          Rectangle {
            id: gitCard
            Layout.fillWidth: true
            Layout.minimumHeight: 320
            color: surfaceCard
            radius: 16
            scale: 1.0
            Behavior on scale { SpringAnimation { spring: 4; damping: 0.8 } }

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 20
              spacing: 12

              // Title
              RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                  text: ""
                  font.pixelSize: 16; color: primary
                }
                Text {
                  text: "Git Activity"
                  font.pixelSize: 15; font.weight: Font.Bold
                  color: textPrimary; font.family: fontUI
                  Layout.fillWidth: true
                }
                Text {
                  text: gitStatus === "loading" ? "" : gitStatus === "error" ? "" : ""
                  font.pixelSize: 12; color: gitStatus === "error" ? error : textDim
                  visible: text !== ""
                }
              }

              // Metrics
              GridLayout {
                columns: 4
                columnSpacing: 8; rowSpacing: 8
                Layout.fillWidth: true

                Repeater {
                  model: [
                    { label: "Today", key: "today", icon: "📅" },
                    { label: "Week", key: "week", icon: "📊" },
                    { label: "Month", key: "month", icon: "📈" },
                    { label: "Total", key: "total", icon: "∑" }
                  ]

                  Rectangle {
                    Layout.fillWidth: true; height: 56; radius: 12; color: surfaceHover
                    ColumnLayout {
                      anchors.centerIn: parent; spacing: 2
                      Text {
                        text: gitData ? String(gitData[modelData.key]) : "--"
                        font.pixelSize: 20; font.weight: Font.Bold
                        color: primary; font.family: fontMono
                        Layout.alignment: Qt.AlignHCenter
                      }
                      Text {
                        text: modelData.label
                        font.pixelSize: 10; color: textSecondary; font.family: fontUI
                        Layout.alignment: Qt.AlignHCenter
                      }
                    }
                  }
                }
              }

              // Streak + Repos + Year
              GridLayout {
                columns: 3
                columnSpacing: 8
                Layout.fillWidth: true

                Repeater {
                  model: [
                    { icon: "🔥", text: gitData ? gitData.streak + "d streak" : "--" },
                    { icon: "📦", text: gitData ? gitData.repos + " repos" : "--" },
                    { icon: "📅", text: gitData ? gitData.year + " this yr" : "--" }
                  ]

                  Rectangle {
                    Layout.fillWidth: true; height: 38; radius: 10; color: surfaceHover
                    RowLayout {
                      anchors.centerIn: parent; spacing: 6
                      Text { text: modelData.icon; font.pixelSize: 14 }
                      Text {
                        text: modelData.text
                        font.pixelSize: 12; color: textPrimary; font.family: fontUI
                      }
                    }
                  }
                }
              }

              // Languages
              Text {
                text: "Languages"
                font.pixelSize: 11; font.weight: Font.Bold
                color: textSecondary; font.family: fontUI
                visible: gitLangs.length > 0
                Layout.topMargin: 4
              }

              Repeater {
                model: gitLangs.slice(0, 5)

                Rectangle {
                  Layout.fillWidth: true; height: 20; radius: 4; color: "transparent"
                  RowLayout {
                    anchors.fill: parent; spacing: 6
                    Text {
                      text: modelData.name
                      font.pixelSize: 11; color: textPrimary; font.family: fontUI
                      Layout.preferredWidth: 90; elide: Text.ElideRight
                    }
                    Rectangle {
                      Layout.fillWidth: true; height: 6; radius: 3
                      color: surfaceHover
                      Rectangle {
                        height: 6; radius: 3; color: primary
                        width: gitLangTotal > 0 ? parent.width * modelData.count / gitLangTotal : 0
                      }
                    }
                    Text {
                      text: gitLangTotal > 0 ? Math.round(modelData.count / gitLangTotal * 100) + "%" : ""
                      font.pixelSize: 10; color: textSecondary; font.family: fontMono
                      Layout.preferredWidth: 32; horizontalAlignment: Text.AlignRight
                    }
                  }
                }
              }

              Item { Layout.fillHeight: true }
            }

            MouseArea {
              anchors.fill: parent; hoverEnabled: true
              onEntered: parent.scale = 1.015
              onExited: parent.scale = 1.0
            }
          }

          // ── SYSTEM CARD ──────────────────────────────────────
          Rectangle {
            id: sysCard
            Layout.fillWidth: true
            Layout.minimumHeight: 320
            color: surfaceCard
            radius: 16
            scale: 1.0
            Behavior on scale { SpringAnimation { spring: 4; damping: 0.8 } }

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 20
              spacing: 10

              RowLayout {
                Layout.fillWidth: true
                Text { text: "󰍹"; font.pixelSize: 16; color: primary }
                Text {
                  text: "System"
                  font.pixelSize: 15; font.weight: Font.Bold
                  color: textPrimary; font.family: fontUI
                  Layout.fillWidth: true
                }
                Text {
                  text: sysStatus === "loading" ? "" : ""
                  font.pixelSize: 12; color: textDim
                }
              }

              // Info rows
              Repeater {
                model: [
                  { icon: "󰌢", label: "Kernel" },
                  { icon: "󰀻", label: "Packages" },
                  { icon: "󰓅", label: "Uptime" },
                  { icon: "󰋊", label: "Hostname" }
                ]

                Rectangle {
                  Layout.fillWidth: true; height: 26; radius: 6; color: "transparent"
                  RowLayout {
                    anchors.fill: parent; spacing: 8
                    Text { text: modelData.icon; font.pixelSize: 11; color: textSecondary; Layout.preferredWidth: 18 }
                    Text { text: modelData.label; font.pixelSize: 11; color: textSecondary; font.family: fontUI; Layout.preferredWidth: 58 }
                    Text {
                      text: {
                        if (!sysData) return "--"
                        var v = sysData[modelData.label.toLowerCase()]
                        return v !== undefined ? String(v) : "--"
                      }
                      font.pixelSize: 12; color: textPrimary; font.family: fontMono
                      Layout.fillWidth: true; elide: Text.ElideRight
                    }
                  }
                }
              }

              // Disk
              Rectangle {
                Layout.fillWidth: true; height: 36; radius: 8; color: surfaceHover
                ColumnLayout {
                  anchors.fill: parent; anchors.margins: 8; spacing: 4
                  RowLayout {
                    Layout.fillWidth: true
                    Text { text: "󰋊 Disk"; font.pixelSize: 10; color: textSecondary; font.family: fontUI }
                    Item { Layout.fillWidth: true }
                    Text {
                      text: sysData ? sysData.disk_used + " / " + sysData.disk_total : "--"
                      font.pixelSize: 10; color: textPrimary; font.family: fontMono
                    }
                  }
                  Rectangle {
                    Layout.fillWidth: true; height: 4; radius: 2; color: surfaceDim
                    Rectangle {
                      height: 4; radius: 2
                      color: sysData && sysData.disk_pct > 85 ? warning : primary
                      width: parent.width * Math.min((sysData ? sysData.disk_pct : 0) / 100, 1)
                    }
                  }
                }
              }

              // Memory
              Rectangle {
                Layout.fillWidth: true; height: 36; radius: 8; color: surfaceHover
                ColumnLayout {
                  anchors.fill: parent; anchors.margins: 8; spacing: 4
                  RowLayout {
                    Layout.fillWidth: true
                    Text { text: "󰍛 Memory"; font.pixelSize: 10; color: textSecondary; font.family: fontUI }
                    Item { Layout.fillWidth: true }
                    Text {
                      text: sysData ? sysData.mem_pct + "%" : "--"
                      font.pixelSize: 10; color: textPrimary; font.family: fontMono
                    }
                  }
                  Rectangle {
                    Layout.fillWidth: true; height: 4; radius: 2; color: surfaceDim
                    Rectangle {
                      height: 4; radius: 2
                      color: sysData && sysData.mem_pct > 80 ? warning : accent
                      width: parent.width * Math.min((sysData ? sysData.mem_pct : 0) / 100, 1)
                    }
                  }
                }
              }

              // Top processes
              Text {
                text: "Top Processes"
                font.pixelSize: 11; font.weight: Font.Bold
                color: textSecondary; font.family: fontUI
                visible: sysApps.length > 0
                Layout.topMargin: 4
              }

              Repeater {
                model: sysApps.slice(0, 5)

                Rectangle {
                  Layout.fillWidth: true; height: 20; radius: 4; color: "transparent"
                  RowLayout {
                    anchors.fill: parent; spacing: 6
                    Text { text: "·"; font.pixelSize: 14; color: primary }
                    Text {
                      text: modelData.name
                      font.pixelSize: 11; color: textPrimary; font.family: fontUI
                      Layout.fillWidth: true; elide: Text.ElideRight
                    }
                    Text {
                      text: String(modelData.count)
                      font.pixelSize: 10; color: textDim; font.family: fontMono
                    }
                  }
                }
              }

              Item { Layout.fillHeight: true }
            }

            MouseArea {
              anchors.fill: parent; hoverEnabled: true
              onEntered: parent.scale = 1.015
              onExited: parent.scale = 1.0
            }
          }
        }

        // ══════════════════  TIMELINE  ═════════════════════════
        Rectangle {
          id: timelineCard
          Layout.fillWidth: true
          Layout.minimumHeight: 140
          color: surfaceCard
          radius: 16
          scale: 1.0
          Behavior on scale { SpringAnimation { spring: 4; damping: 0.8 } }

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 8

            RowLayout {
              Layout.fillWidth: true
              Text { text: "󱑇"; font.pixelSize: 16; color: primary }
              Text {
                text: "Activity"
                font.pixelSize: 15; font.weight: Font.Bold
                color: textPrimary; font.family: fontUI
                Layout.fillWidth: true
              }
              Text {
                text: actStatus === "loading" ? "" : ""
                font.pixelSize: 12; color: textDim
              }
            }

            Repeater {
              model: actEvents.slice(0, 10)

              Rectangle {
                Layout.fillWidth: true; height: 26; radius: 6
                color: index % 2 === 0 ? "transparent" : surfaceHover
                RowLayout {
                  anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 8
                  Text {
                    text: modelData.time
                    font.pixelSize: 11; color: textDim; font.family: fontMono
                    Layout.preferredWidth: 44
                  }
                  Text {
                    text: modelData.icon || "·"
                    font.pixelSize: 11; color: textSecondary
                    Layout.preferredWidth: 20
                  }
                  Text {
                    text: modelData.text
                    font.pixelSize: 11; color: textPrimary; font.family: fontUI
                    Layout.fillWidth: true; elide: Text.ElideRight
                    clip: true
                  }
                }
              }
            }

            Text {
              text: actEvents.length === 0 ? (actStatus === "loading" ? "Loading..." : "No recent events") : ""
              font.pixelSize: 12; color: textDim; font.family: fontUI
              Layout.alignment: Qt.AlignHCenter
              visible: text !== ""
            }
          }

          MouseArea {
            anchors.fill: parent; hoverEnabled: true
            onEntered: parent.scale = 1.005
            onExited: parent.scale = 1.0
          }
        }

        // ── Footer ──────────────────────────────────────────────
        Text {
          text: "BlackNode Dashboard · Updates every minute"
          font.pixelSize: 10; color: textDim; font.family: fontUI
          Layout.alignment: Qt.AlignHCenter
          Layout.bottomMargin: 8
        }
      }
    }
  }

  // ── Clock ─────────────────────────────────────────────────────
  Timer {
    interval: 1000; running: true; repeat: true
    onTriggered: {
      var d = new Date()
      bigTime = d.toLocaleTimeString(Qt.locale(), "HH:mm:ss")
      bigDate = d.toLocaleDateString(Qt.locale(), "dddd, d MMMM yyyy")
    }
  }

  // ── Data Loaders ─────────────────────────────────────────────
  function processGitData(text) {
    try {
      gitData = JSON.parse(text)
      gitStatus = "loaded"

      var langs = []
      var total = 0
      for (var k in gitData.languages) {
        langs.push({name: k, count: gitData.languages[k]})
        total += gitData.languages[k]
      }
      langs.sort(function(a, b) { return b.count - a.count })
      gitLangs = langs
      gitLangTotal = total
    } catch(e) {
      gitStatus = "error"
    }
  }

  function processSysData(text) {
    try {
      sysData = JSON.parse(text)
      sysStatus = "loaded"

      var apps = []
      for (var k in sysData.apps) {
        apps.push({name: k, count: sysData.apps[k]})
      }
      apps.sort(function(a, b) { return b.count - a.count })
      sysApps = apps
    } catch(e) {
      sysStatus = "error"
    }
  }

  function processActData(text) {
    try {
      var d = JSON.parse(text)
      actEvents = d.events || []
      actStatus = "loaded"
    } catch(e) {
      actStatus = "error"
    }
  }

  Process {
    id: gitProc
    command: ["bash", "-c", "~/.config/quickshell/dashboard/scripts/git-stats.sh"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: processGitData(this.text)
    }
  }

  Process {
    id: sysProc
    command: ["bash", "-c", "~/.config/quickshell/dashboard/scripts/sys-stats.sh"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: processSysData(this.text)
    }
  }

  Process {
    id: actProc
    command: ["bash", "-c", "~/.config/quickshell/dashboard/scripts/activity.sh"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: processActData(this.text)
    }
  }

  Timer {
    interval: 60000; running: true; repeat: true
    onTriggered: {
      gitProc.running = true
      sysProc.running = true
      actProc.running = true
    }
  }
}
