import QtQuick
import qs.services.clipboard

Rectangle {
    id: card

    property string thumbColor: "#1c1c1e"
    property string thumbImage: ""
    property string title: ""
    property string subtitle: ""
    property string metaText: ""
    property string sourceIconColor: "#4285f4"
    property bool showOverlayText: false
    property bool isFavorite: false
    property var itemData: null

    radius: 16
    color: mouseArea.containsMouse ? "#252528" : thumbColor
    clip: true

    Behavior on color { ColorAnimation { duration: 100 } }

    signal clicked()

    Image {
        anchors.fill: parent
        source: card.thumbImage
        fillMode: Image.PreserveAspectCrop
        visible: card.thumbImage !== ""
        sourceSize.width: 200
        sourceSize.height: 200
        asynchronous: true
    }

    Rectangle {
        visible: card.showOverlayText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Math.round(parent.height * 0.55)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#cc000000" }
        }
    }

    Column {
        visible: card.showOverlayText && card.title !== ""
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        anchors.bottomMargin: 26
        spacing: 2

        Text {
            width: parent.width
            text: card.title
            color: "#ffffff"
            font.pixelSize: 11
            font.weight: 600
            wrapMode: Text.WordWrap
        }
        Text {
            width: parent.width
            text: card.subtitle
            color: "#cccccc"
            font.pixelSize: 9
            wrapMode: Text.WordWrap
            visible: card.subtitle !== ""
        }
    }

    Column {
        visible: !card.showOverlayText && card.title !== ""
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 3

        Text {
            width: parent.width
            text: card.title
            color: "#f2f2f2"
            font.pixelSize: 11
            font.weight: 500
            wrapMode: Text.WordWrap
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        height: 16

        Row {
            anchors.left: parent.left
            spacing: 5

            Rectangle {
                width: 6; height: 6; radius: 3
                color: card.sourceIconColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: card.metaText
                color: "#6e6e6e"
                font.pixelSize: 9
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            visible: card.isFavorite
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 16; height: 16; radius: 8
            color: "#ff453a"
            Text {
                anchors.centerIn: parent
                text: "\u2665"
                color: "#ffffff"
                font.pixelSize: 9
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                if (card.itemData) ClipboardService.toggleFavorite(card.itemData)
            } else {
                if (card.itemData) ClipboardService.copyToClipboard(card.itemData)
                card.clicked()
            }
        }
    }
}
