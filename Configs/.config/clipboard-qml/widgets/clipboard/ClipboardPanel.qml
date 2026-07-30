import QtQuick
import QtQuick.Layouts
import qs.services.clipboard
import qs.widgets.clipboard

Rectangle {
    id: panel

    width: 1000
    height: 300
    radius: 28
    color: "#0d0d0d"
    border.width: 1
    border.color: "#2a2a2a"

    visible: panelVisible
    opacity: panelVisible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    property int activeTab: 0
    property bool panelVisible: false
    property int carouselOffset: 0
    readonly property int visibleCount: 6
    property var displayItems: []

    readonly property int emptySlots: Math.max(0, visibleCount - displayItems.length)

    function _getModel() {
        if (activeTab === 0) return ClipboardService.recentItems || []
        if (activeTab === 1) return ClipboardService.favorites || []
        if (activeTab === 3) {
            var imgs = []
            var all = ClipboardService.recentItems || []
            for (var i = 0; i < all.length; i++) {
                if (all[i].type === "image") imgs.push(all[i])
            }
            return imgs
        }
        return []
    }

    readonly property int totalItems: {
        var _ = activeTab
        return _getModel().length
    }
    readonly property bool canScroll: totalItems > visibleCount
    readonly property real scrollMax: Math.max(1, totalItems - visibleCount)
    readonly property real scrollRatio: canScroll ? carouselOffset / scrollMax : 0
    readonly property real indicatorWidth: canScroll ? Math.max(32, (visibleCount / totalItems) * cardsArea.width) : 0

    property bool _scrollIndicatorVisible: false

    onCarouselOffsetChanged: { _updateDisplay(); _showScrollIndicator() }
    onPanelVisibleChanged: _updateDisplay()
    onActiveTabChanged: { carouselOffset = 0; _updateDisplay() }

    Connections {
        target: ClipboardService
        function onRecentItemsChanged() { panel._updateDisplay() }
        function onFavoritesChanged() { panel._updateDisplay() }
    }

    function _updateDisplay() {
        var items = _getModel()
        if (items.length === 0) {
            displayItems = []
            return
        }
        var start = Math.min(carouselOffset, Math.max(0, items.length - visibleCount))
        if (carouselOffset !== start) carouselOffset = start
        displayItems = items.slice(start, start + visibleCount)
    }

    function _showScrollIndicator() {
        if (!canScroll) return
        _scrollIndicatorVisible = true
        scrollFadeTimer.restart()
    }

    function show() { panelVisible = true; autoHideTimer.stop() }
    function hide() { panelVisible = false }

    Timer { id: autoHideTimer; interval: 1500; onTriggered: panel.hide() }
    Timer { id: scrollFadeTimer; interval: 1200; onTriggered: panel._scrollIndicatorVisible = false }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: autoHideTimer.stop()
        onExited: autoHideTimer.restart()
        onWheel: function(wheel) {
            if (!canScroll) return
            if (wheel.angleDelta.y < 0) { if (carouselOffset < scrollMax) carouselOffset++ }
            else { if (carouselOffset > 0) carouselOffset-- }
            wheel.accepted = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 16
            spacing: 12

            Text {
                text: "BlackNode Clipboard"
                color: "#ffffff"
                font.pixelSize: 15
                font.weight: 600
            }

            Item { Layout.fillWidth: true }

            Text {
                id: clockLabel
                text: "00:00"
                color: "#e0e0e0"
                font.pixelSize: 15
                font.weight: 500
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 20
            spacing: 8

            CategoryTab { label: "History"; count: ClipboardService.recentItems ? ClipboardService.recentItems.length : 0; active: panel.activeTab === 0; onClicked: panel.activeTab = 0 }
            CategoryTab { label: "Favorites"; count: ClipboardService.favorites ? ClipboardService.favorites.length : 0; active: panel.activeTab === 1; onClicked: panel.activeTab = 1 }
            CategoryTab { label: "Colors"; count: 0; active: panel.activeTab === 2; onClicked: panel.activeTab = 2 }
            CategoryTab { label: "Assets"; count: activeTab === 3 ? totalItems : 0; active: panel.activeTab === 3; onClicked: panel.activeTab = 3 }
            CategoryTab { label: "Inspirations"; count: 0; active: panel.activeTab === 4; onClicked: panel.activeTab = 4 }

            Rectangle {
                width: 30; height: 30; radius: 15
                color: addArea.containsMouse ? "#2a2a2a" : "transparent"
                border.width: 1
                border.color: "#3a3a3a"
                Text { anchors.centerIn: parent; text: "+"; color: "#9a9a9a"; font.pixelSize: 15 }
                MouseArea { id: addArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: {} }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: panel.totalItems + " items"
                color: "#6e6e6e"
                font.pixelSize: 11
                visible: panel.totalItems > 0
            }
        }

        Item {
            id: cardsArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                id: cardsRow
                anchors.fill: parent
                anchors.bottomMargin: panel.canScroll ? 14 : 0
                spacing: 8

                Repeater {
                    model: panel.displayItems
                    delegate: ClipboardCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        thumbColor: "#1c1c1e"
                        showOverlayText: modelData.type === "image"
                        thumbImage: modelData.type === "image" ? "file://" + modelData.imagePath : ""
                        metaText: modelData.time || ""
                        title: modelData.type === "text" ? modelData.content : "Image"
                        sourceIconColor: modelData.type === "text" ? "#4285f4" : "#fbbc04"
                        isFavorite: ClipboardService.isFavorite(modelData)
                        itemData: modelData
                    }
                }

                Repeater {
                    model: panel.emptySlots
                    delegate: ClipboardCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        thumbColor: "#141414"
                        showOverlayText: false
                        metaText: ""
                        title: ""
                        sourceIconColor: "#2a2a2a"
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                width: panel.indicatorWidth
                height: 4
                radius: 2
                color: "#4a4a4a"
                opacity: panel._scrollIndicatorVisible ? 0.8 : 0
                visible: panel.canScroll
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                x: (cardsArea.width - width) * panel.scrollRatio
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: function() {
            var now = new Date()
            clockLabel.text = now.getHours().toString().padStart(2, "0") + ":" + now.getMinutes().toString().padStart(2, "0")
        }
    }

    Component.onCompleted: _updateDisplay()
}
