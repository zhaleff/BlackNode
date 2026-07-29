pragma Singleton
import QtQuick

QtObject {
    readonly property color primary: "#94cdf7"
    readonly property color primaryText: "#00344d"
    readonly property color surface: "#f5efe6"
    readonly property color surfaceText: "#1b1b1b"
    readonly property color icon: "#1b1b1b"
    readonly property color primaryContainer: "#004c6e"
    readonly property color primaryContainerText: "#c9e6ff"
    readonly property color secondary: "#b7c9d9"
    readonly property color secondaryText: "#21323f"
    readonly property color secondaryContainer: "#384956"
    readonly property color secondaryContainerText: "#d3e5f5"
    readonly property color tertiary: "#cec0e8"
    readonly property color tertiaryText: "#352b4b"
    readonly property color tertiaryContainer: "#4c4163"
    readonly property color tertiaryContainerText: "#eaddff"
    readonly property color error: "#ffb4ab"
    readonly property color errorText: "#690005"
    readonly property color errorContainer: "#93000a"
    readonly property color errorContainerText: "#ffdad6"
    readonly property color outline: "#7a7a7a"

    function alpha(base, a) {
        return Qt.rgba(base.r, base.g, base.b, a)
    }
}
