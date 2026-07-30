pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var recentItems: []
    property var favorites: []
    property string currentText: ""
    property int maxItems: 50
    property string lastImageHash: ""
    property bool ready: false

    readonly property string historyPath: Qt.resolvedUrl("../../clipboard_history.json").toString().slice(7)
    readonly property string thumbsDir: Qt.resolvedUrl("../../thumbs/").toString().slice(7)
    property int _thumbCounter: 0

    FileView {
        id: historyFile
        path: root.historyPath
        preload: false
        onLoaded: root._loadFromDisk()
    }

    Process {
        id: mkdirProcess
        command: ["mkdir", "-p", root.thumbsDir]
        running: false
        onRunningChanged: if (!running) root._initComplete()
    }

    Process {
        id: textProcess
        command: ["wl-paste", "--type", "text"]
        running: false
        stdout: SplitParser {
            onRead: data => root._onTextCaptured(data)
        }
    }

    Process {
        id: imageWriteProcess
        command: ["bash", "-c", "wl-paste --type image/png 2>/dev/null > \"" + root.thumbsDir + "current.png\""]
        running: false
        onRunningChanged: if (!running) root._checkImage()
    }

    Process {
        id: checkImageProcess
        command: ["bash", "-c", "test -s \"" + root.thumbsDir + "current.png\" && echo OK || echo EMPTY"]
        running: false
        stdout: SplitParser {
            onRead: line => {
                if (line.trim() === "OK") root._hashImage()
            }
        }
    }

    Process {
        id: hashProcess
        command: ["bash", "-c", "md5sum \"" + root.thumbsDir + "current.png\" | cut -d' ' -f1"]
        running: false
        stdout: SplitParser {
            onRead: line => root._onImageHash(line.trim())
        }
    }

    Timer {
        interval: 2000
        running: root.ready
        repeat: true
        onTriggered: root.pollClipboard()
    }

    Component.onCompleted: mkdirProcess.running = true

    function _initComplete() {
        historyFile.setText("{}")
        historyFile.reload()
        root.ready = true
        pollClipboard()
    }

    function _loadFromDisk() {
        try {
            var raw = historyFile.text()
            if (!raw || raw.trim() === "") return
            var data = JSON.parse(raw)
            if (data && data.items && Array.isArray(data.items)) {
                root.recentItems = data.items
                root._thumbCounter = data.items.length
            }
            if (data && data.favorites && Array.isArray(data.favorites)) {
                root.favorites = data.favorites
            }
            if (root.recentItems.length > 0) {
                var first = root.recentItems[0]
                if (first.type === "text") root.currentText = first.fullContent || ""
                else root.currentText = "__image__"
            }
        } catch(e) { }
    }

    function _saveToDisk() {
        try {
            var data = { items: root.recentItems, favorites: root.favorites }
            historyFile.setText(JSON.stringify(data, null, 2))
        } catch(e) { }
    }

    function pollClipboard() {
        if (!textProcess.running) textProcess.running = true
        if (!imageWriteProcess.running) imageWriteProcess.running = true
    }

    function _onTextCaptured(data) {
        if (!data) return
        var text = data.trim()
        if (text === "" || text === root.currentText) return
        root.currentText = text
        if (root.recentItems.length > 0 && root.recentItems[0].type === "text" && root.recentItems[0].fullContent === text) return
        var item = {
            type: "text",
            content: text.length > 100 ? text.substring(0, 100) + "..." : text,
            fullContent: text,
            time: _timeNow(),
            pinned: false,
            id: _uid()
        }
        root.recentItems = [item].concat(root.recentItems).slice(0, root.maxItems)
        _saveToDisk()
    }

    function _checkImage() {
        if (!checkImageProcess.running) checkImageProcess.running = true
    }

    function _hashImage() {
        if (!hashProcess.running) hashProcess.running = true
    }

    function _onImageHash(hash) {
        if (!hash || hash === "" || hash === root.lastImageHash) return
        root.lastImageHash = hash
        root.currentText = "__image__"
        if (root.recentItems.length > 0 && root.recentItems[0].type === "image" && root.recentItems[0].imageHash === hash) return

        var destPath = root.thumbsDir + "clip_" + root._thumbCounter + ".png"
        var cpProc = _createProcess(["cp", root.thumbsDir + "current.png", destPath])
        cpProc.running = true
        root._thumbCounter++

        var item = {
            type: "image",
            content: "Image",
            fullContent: "",
            imagePath: destPath,
            imageHash: hash,
            time: _timeNow(),
            pinned: false,
            id: _uid()
        }
        root.recentItems = [item].concat(root.recentItems).slice(0, root.maxItems)
        _saveToDisk()
    }

    function copyToClipboard(item) {
        if (item.type === "text") {
            var p = _createProcess(["bash", "-c", "printf '%s' " + _shellEscape(item.fullContent) + " | wl-copy"])
            p.running = true
        } else if (item.type === "image" && item.imagePath) {
            var p2 = _createProcess(["bash", "-c", "cat \"" + item.imagePath + "\" | wl-copy --type image/png"])
            p2.running = true
        }
    }

    function toggleFavorite(item) {
        var idx = -1
        for (var i = 0; i < root.favorites.length; i++) {
            if (root.favorites[i].id === item.id) { idx = i; break }
        }
        if (idx >= 0) {
            root.favorites.splice(idx, 1)
        } else {
            var fav = JSON.parse(JSON.stringify(item))
            fav.pinned = true
            root.favorites = [fav].concat(root.favorites)
        }
        for (var j = 0; j < root.recentItems.length; j++) {
            if (root.recentItems[j].id === item.id) {
                root.recentItems[j].pinned = !root.recentItems[j].pinned
                break
            }
        }
        root.recentItems = root.recentItems.slice()
        _saveToDisk()
    }

    function isFavorite(item) {
        for (var i = 0; i < root.favorites.length; i++) {
            if (root.favorites[i].id === item.id) return true
        }
        return false
    }

    function removeItem(id) {
        root.recentItems = root.recentItems.filter(function(i) { return i.id !== id })
        root.favorites = root.favorites.filter(function(i) { return i.id !== id })
        _saveToDisk()
    }

    function clearHistory() {
        root.recentItems = []
        root.currentText = ""
        _saveToDisk()
    }

    function _timeNow() {
        var now = new Date()
        return now.getHours().toString().padStart(2, "0") + ":" + now.getMinutes().toString().padStart(2, "0")
    }

    property int _counter: 0
    function _uid() {
        _counter++
        return Date.now().toString(36) + "_" + _counter.toString(36)
    }

    function _shellEscape(s) {
        return "'" + s.replace(/'/g, "'\\''") + "'"
    }

    function _createProcess(cmd) {
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ' + JSON.stringify(cmd) + ' }', root)
        return proc
    }
}
