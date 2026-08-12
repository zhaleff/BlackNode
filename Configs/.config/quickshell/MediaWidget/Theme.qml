pragma Singleton
import QtQuick

QtObject {
    readonly property color surface: "#141110"
    readonly property color surfaceVariant: "#1c1815"
    readonly property color text: "#f5efe6"
    readonly property color textMuted: "#a89d8f"
    readonly property color primary: "#e8c88a"
    readonly property color accentText: "#141110"
    readonly property color outline: "#2c2622"

    readonly property int radiusPanel: 28
    readonly property int radiusButton: 999
    readonly property int radiusArt: 20

    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24

    readonly property string fontFamily: "Inter"
}
