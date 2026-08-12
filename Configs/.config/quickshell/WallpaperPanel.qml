import QtQuick 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls 6.0
import Qt5Compat.GraphicalEffects
import "./" as Root

Item {
    id: root
    property alias wallpaperModel: view.model
    property int panelMargin: 24
    property int spacing: 12
    property int baseColumns: 4
    property real cellSize: (width - (baseColumns - 1) * spacing - 2 * panelMargin) / baseColumns
    signal applied(int index)
    property int currentIndex: -1

    function select(index) {
        currentIndex = index
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        color: Root.Colors.surfaceContainer

        Flickable {
            anchors.fill: parent
            anchors.margins: root.panelMargin
            contentWidth: width
            contentHeight: flow.height
            clip: true
            ScrollBar.vertical: ScrollBar {}

            Flow {
                id: flow
                width: parent.width
                spacing: root.spacing

                Repeater {
                    id: view
                    model: root.wallpaperModel

                    delegate: WallpaperCard {
                        width: root.cellSize * (model.index === 0 ? 2 : 1) + (model.index === 0 ? root.spacing : 0)
                        height: root.cellSize
                        source: model.source
                        name: model.name
                        resolution: model.resolution
                        selected: root.currentIndex === model.index
                        onCardClicked: {
                            root.currentIndex = model.index
                            root.applied(model.index)
                        }
                    }
                }
            }
        }
    }

    component WallpaperCard: Item {
        id: card
        property string source: ""
        property string name: ""
        property string resolution: ""
        property bool selected: false
        property bool entered: false
        property real cardRadius: (selected || entered) ? 34 : 28
        width: root.cellSize
        height: root.cellSize
        signal cardClicked

        function applyRadius() {
            surface.radius = cardRadius
            frame.radius = cardRadius
            artClip.radius = Math.max(16, cardRadius - 8)
        }

        Component.onCompleted: applyRadius()
        onSelectedChanged: applyRadius()
        onEnteredChanged: applyRadius()

        Rectangle {
            id: surface
            anchors.fill: parent
            color: Root.Colors.surfaceContainer
            radius: 28
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: selected ? 2 : 0
                radius: selected ? 24 : 12
                samples: selected ? 48 : 24
                color: Root.Colors.surfaceInk
                opacity: selected ? 0.4 : 0.0
            }
            Behavior on radius {
                NumberAnimation { duration: 400; easing.type: Easing.OutBack }
            }
        }

        Rectangle {
            id: artClip
            anchors.fill: parent
            anchors.margins: 8
            radius: 20
            clip: true
            Behavior on radius {
                NumberAnimation { duration: 400; easing.type: Easing.OutBack }
            }

            Image {
                id: art
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: card.source
                scale: card.selected ? 1.04 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 350; easing.type: Easing.OutBack }
                }
            }
        }

        Rectangle {
            id: info
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.bottomMargin: 8
            height: 44
            color: Root.Colors.surfaceContainerHigh
            radius: 20

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1
                Text {
                    width: parent.width
                    text: card.name
                    elide: Text.ElideRight
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Root.Colors.surfaceInk
                }
                Text {
                    width: parent.width
                    text: card.resolution
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    color: Root.Colors.surfaceVariantInk
                }
            }
        }

        Rectangle {
            id: frame
            anchors.fill: parent
            radius: 28
            color: "transparent"
            border.width: 4
            border.color: Root.Colors.primary
            opacity: card.selected ? 1 : 0
            scale: card.selected ? 1 : 0.92
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.OutBack }
            }
            Behavior on scale {
                NumberAnimation { duration: 400; easing.type: Easing.OutBack }
            }
            Behavior on radius {
                NumberAnimation { duration: 400; easing.type: Easing.OutBack }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: card.cardClicked()
            onEntered: card.entered = true
            onExited: card.entered = false
        }
    }
}