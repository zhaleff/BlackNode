import QtQuick

QtObject {
    readonly property color ink:        "#0D0E10"
    readonly property color panel:      "#141519"
    readonly property color panelAlt:   "#1B1D22"
    readonly property color line:       "#2A2C30"
    readonly property color lineStrong: "#3D4046"
    readonly property color paper:      "#E8E6E1"
    readonly property color mute:       "#6B6E76"
    readonly property color muteDim:    "#4A4D53"
    readonly property color accent:     "#C93B2E"
    readonly property color accentDim:  "#7A2620"
    readonly property color ok:         "#3B7A57"
    readonly property color warn:       "#B8862E"

    readonly property string fBody:  "Inter"
    readonly property string fMono:  "JetBrains Mono"
    readonly property string fIcons: "Symbols Nerd Font"

    readonly property int fsLabel: 11
    readonly property int fsBody:  13
    readonly property int fsTitle: 16

    readonly property int barH:       44
    readonly property int pillH:      34
    readonly property int radiusHair: 2

    readonly property int topbarMarginH: 12
    readonly property int topbarMarginV: 8

    readonly property int wsPadPill:      8
    readonly property int wsPadCell:      14
    readonly property int wsMinCell:      34
    readonly property int wsSpacing:      0
    readonly property int wsIndicatorWidth: 8
    readonly property real wsIndicatorHeight: 0.2
    readonly property int wsSeparatorWidth: 1
    readonly property real wsSeparatorHeight: 0.6

    readonly property int sysPadPill:      10
    readonly property int sysPadCell:      12
    readonly property int sysIconSize:     20
    readonly property int sysSpacing:      0
    readonly property int sysSeparatorWidth: 1
    readonly property real sysSeparatorHeight: 0.6

    readonly property int titlePadH: 20
    readonly property int titleMaxW: 400
}
