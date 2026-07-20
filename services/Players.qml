pragma Singleton
import QtQml
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Io
import "."

Singleton {
    id: root
    readonly property list<MprisPlayer> list: Mpris.players.values
    property MprisPlayer active: null

    readonly property string title: active ? (active.trackTitle ?? "No track") : "No track"
    readonly property string artist: active ? (active.trackArtist ?? "") : ""
    readonly property string album: active ? (active.trackAlbum ?? "") : ""
    property string cover: active ? String(active.trackArtUrl || active.metadata["mpris:artUrl"] || "") : ""

    function getArtUrl() { return cover }

    property int mediaVersion: 0
    property int refreshArt: 0
    property bool isPlaying: active ? active.playbackState === MprisPlaybackState.Playing : false
    property string loopStatus: active ? String(active.loopStatus) : "None"
    property int tauonLoopState: 0

    Process { id: loopCmd }
    Process { id: shuffleCmd }

    function updateActivePlayer() {
        let blacklist = ["mpv"]
        let players = list.filter(p => {
            let id = String(p.identity ?? "").toLowerCase()
            let bus = String(p.busName ?? "").toLowerCase()
            return !blacklist.some(x => id.includes(x) || bus.includes(x))
        })

        let playing = players.find(p => p.playbackState === MprisPlaybackState.Playing)
        if (playing) { root.active = playing; return }

        let preferred = ["tauon", "spotify", "vlc", "chromium", "firefox"]
        for (let name of preferred) {
            let p = players.find(player => String(player.identity ?? "").toLowerCase().includes(name))
            if (p) { root.active = p; return }
        }
        root.active = players.length > 0 ? players[0] : null
    }

    onListChanged: updateActivePlayer()

    Connections {
        target: Mpris
        ignoreUnknownSignals: true
        function onPlayerChanged() { root.updateActivePlayer() }
    }

    // Kết nối động an toàn, tự động cập nhật khi đổi trình phát nhạc
    Connections {
        target: root
        ignoreUnknownSignals: true
        function onActiveChanged() {
            if (root.active) {
                root.isPlaying = (root.active.playbackState === MprisPlaybackState.Playing)
                root.loopStatus = String(root.active.loopStatus)

                root.active.playbackStateChanged.disconnect(updatePlaying)
                root.active.playbackStateChanged.connect(updatePlaying)
                root.active.loopStatusChanged.disconnect(updateLoop)
                root.active.loopStatusChanged.connect(updateLoop)
                root.active.trackArtUrlChanged.disconnect(updateArt)
                root.active.trackArtUrlChanged.connect(updateArt)
            } else {
                root.isPlaying = false
                root.loopStatus = "None"
            }
        }
    }

    function updatePlaying() { root.isPlaying = root.active && root.active.playbackState === MprisPlaybackState.Playing }
    function updateLoop() { root.loopStatus = String(root.active.loopStatus) }
    function updateArt() { root.mediaVersion++; console.log("NEW ART:", root.cover) }

    function forceToggleLoop() {
        if (!root.active) return
            let playerIdentity = String(root.active.identity || "").toLowerCase()

            if (playerIdentity.includes("tauon")) {
                root.tauonLoopState = (root.tauonLoopState + 1) % 3
                let tauonMode = root.tauonLoopState === 1 ? "track" : (root.tauonLoopState === 2 ? "playlist" : "none")
                loopCmd.command = ["bash", "-c", "playerctl --player=tauon loop " + tauonMode]
                loopCmd.running = false; loopCmd.running = true
                return
            }

            let currentStatus = root.active.loopStatus
            let nextMode = currentStatus === 0 ? "track" : (currentStatus === 1 ? "playlist" : "none")
            loopCmd.command = ["bash", "-c", "playerctl --player=" + playerIdentity + " loop " + nextMode]
            loopCmd.running = false; loopCmd.running = true
    }

    function toggleShuffle() {
        if (!root.active) return
            let playerIdentity = String(root.active.identity || "").toLowerCase()
            if (playerIdentity.includes("tauon")) {
                root.active.shuffle = !root.active.shuffle
                return
            }
            shuffleCmd.command = ["bash", "-c", "playerctl --player=" + playerIdentity + " shuffle toggle"]
            shuffleCmd.running = false; shuffleCmd.running = true
    }

    Component.onCompleted: updateActivePlayer()
}
