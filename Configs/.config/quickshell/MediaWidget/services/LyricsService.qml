pragma Singleton
import QtQuick

QtObject {
    id: root

    property var lines: []
    property int currentIndex: -1
    property bool loading: false
    property bool available: false

    property string lastQueryKey: ""

    function timeToMs(tag) {
        var m = tag.match(/(\d+):(\d+(?:\.\d+)?)/)
        if (!m) return -1
        return (parseInt(m[1]) * 60 + parseFloat(m[2])) * 1000
    }

    function parseLrc(raw) {
        var out = []
        var rawLines = raw.split("\n")
        for (var i = 0; i < rawLines.length; i++) {
            var line = rawLines[i]
            var tagMatches = line.match(/\[(\d+:\d+(?:\.\d+)?)\]/g)
            if (!tagMatches) continue
            var text = line.replace(/\[\d+:\d+(?:\.\d+)?\]/g, "").trim()
            for (var j = 0; j < tagMatches.length; j++) {
                var ms = timeToMs(tagMatches[j])
                if (ms >= 0) {
                    out.push({ time: ms, text: text })
                }
            }
        }
        out.sort(function (a, b) { return a.time - b.time })
        return out
    }

    function fetchFor(title, artist, album, durationSeconds) {
        if (!title || !artist) {
            lines = []
            available = false
            return
        }

        var key = artist + "::" + title
        if (key === lastQueryKey) return
        lastQueryKey = key

        loading = true
        available = false
        lines = []
        currentIndex = -1

        var url = "https://lrclib.net/api/get?"
            + "artist_name=" + encodeURIComponent(artist)
            + "&track_name=" + encodeURIComponent(title)
        if (album) url += "&album_name=" + encodeURIComponent(album)
        if (durationSeconds > 0) url += "&duration=" + Math.round(durationSeconds)

        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            loading = false

            if (xhr.status !== 200) {
                available = false
                return
            }

            try {
                var data = JSON.parse(xhr.responseText)
                if (data.syncedLyrics) {
                    lines = parseLrc(data.syncedLyrics)
                    available = lines.length > 0
                } else if (data.plainLyrics) {
                    var plain = data.plainLyrics.split("\n")
                    var out = []
                    for (var i = 0; i < plain.length; i++) {
                        out.push({ time: -1, text: plain[i] })
                    }
                    lines = out
                    available = lines.length > 0
                } else {
                    available = false
                }
            } catch (e) {
                available = false
            }
        }
        xhr.open("GET", url)
        xhr.send()
    }

    function updatePosition(positionMs) {
        if (lines.length === 0) return
        var idx = -1
        for (var i = 0; i < lines.length; i++) {
            if (lines[i].time <= positionMs) {
                idx = i
            } else {
                break
            }
        }
        currentIndex = idx
    }
}
