import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "./components" as Components
import "./services" as Services
import "./" as Root

Rectangle {
    id: root

    implicitWidth: 720
    implicitHeight: 320
    radius: Root.Theme.radiusPanel
    color: Root.Theme.surface

    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    readonly property string trackTitle: player ? (player.trackTitle || "") : ""
    readonly property string trackArtist: player ? (player.trackArtist || "") : ""
    readonly property string trackAlbum: player ? (player.trackAlbum || "") : ""
    readonly property string artUrl: player ? (player.artUrl || "") : ""
    readonly property bool isPlaying: player ? (player.playbackState === MprisPlaybackState.Playing) : false
    readonly property real positionMs: player ? (player.position * 1000) : 0
    readonly property real lengthMs: player ? (player.length * 1000) : 1

    onTrackTitleChanged: fetchLyricsTimer.restart()
    onTrackArtistChanged: fetchLyricsTimer.restart()

    Timer {
        id: fetchLyricsTimer
        interval: 400
        repeat: false
        onTriggered: {
            Services.LyricsService.fetchFor(
                root.trackTitle,
                root.trackArtist,
                root.trackAlbum,
                root.lengthMs / 1000
            )
        }
    }

    Timer {
        interval: 250
        running: root.isPlaying
        repeat: true
        onTriggered: {
            Services.LyricsService.updatePosition(root.positionMs)
        }
    }

    readonly property real currentLineProgress: {
        var idx = Services.LyricsService.currentIndex
        var lines = Services.LyricsService.lines
        if (idx < 0 || idx >= lines.length) return 0
        var start = lines[idx].time
        var end = (idx + 1 < lines.length) ? lines[idx + 1].time : root.lengthMs
        if (end <= start) return 1
        return Math.max(0, Math.min(1, (root.positionMs - start) / (end - start)))
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Root.Theme.spacingLarge
        spacing: Root.Theme.spacingLarge

        Components.ProgressIndicator {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            positionMs: root.positionMs
            lengthMs: root.lengthMs
            playing: root.isPlaying
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Root.Theme.spacingLarge

            ColumnLayout {
                Layout.preferredWidth: 260
                Layout.fillHeight: true
                spacing: 0

                Components.AlbumArt {
                    Layout.alignment: Qt.AlignHCenter
                    artSource: root.artUrl
                    artSize: 200
                }

                Item { Layout.fillHeight: true }

                Components.PlaybackControls {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: Root.Theme.spacingLarge
                    playing: root.isPlaying
                    canGoNext: root.player ? root.player.canGoNext : false
                    canGoPrevious: root.player ? root.player.canGoPrevious : false
                    onPlayPauseRequested: if (root.player) root.player.togglePlaying()
                    onNextRequested: if (root.player) root.player.next()
                    onPreviousRequested: if (root.player) root.player.previous()
                    onShuffleRequested: if (root.player && root.player.shuffleSupported) root.player.shuffle = !root.player.shuffle
                    onRepeatRequested: if (root.player) root.player.loopState =
                        root.player.loopState === MprisLoopState.None ? MprisLoopState.Track : MprisLoopState.None
                    shuffleActive: root.player ? !!root.player.shuffle : false
                    repeatActive: root.player ? root.player.loopState !== MprisLoopState.None : false
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.topMargin: Root.Theme.spacingLarge
                Layout.bottomMargin: Root.Theme.spacingLarge
                color: Root.Theme.outline
            }

            Components.LyricsView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                lyricsLines: Services.LyricsService.lines
                currentIndex: Services.LyricsService.currentIndex
                currentLineProgress: root.currentLineProgress
                loading: Services.LyricsService.loading
                available: Services.LyricsService.available
            }
        }
    }
}
