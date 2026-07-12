pragma Singleton

import QtQml
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Io

Singleton {
    id: root

    readonly property list<MprisPlayer> list: Mpris.players.values
    property MprisPlayer active: null
    property bool isPlaying: active ? active.playbackState === MprisPlaybackState.Playing : false

    property string currentLyrics: "Loading lyrics..."


    // Biến đệm tối cao ép chu kỳ loop cho Tauon
    property int tauonLoopState: 0

    // CÔ LẬP TIẾN TRÌNH: Chia nhỏ làm 3 bộ máy độc lập hoàn toàn, bẻ gãy lỗi cướp lệnh kẹt luồng
    Process { id: lyricsFetcher }
    Process { id: loopCmd }
    Process { id: shuffleCmd }

    function updateActivePlayer() {
        let blacklist = ["mpvpaper", "paper", "wallpaper"];

        let players = list.filter(p => {
            let id = String(p.identity ?? "").toLowerCase();
            let bus = String(p.busName ?? "").toLowerCase();
            return !blacklist.some(x => id.includes(x) || bus.includes(x));
        });

        let preferred = ["tauon", "spotify", "vlc", "chromium", "firefox"];

        for (let name of preferred) {
            let p = players.find(player => String(player.identity ?? "").toLowerCase().includes(name));
            if (p) {
                root.active = p;
                return;
            }
        }

        let playing = players.find(p => p.playbackState === MprisPlaybackState.Playing);
        if (playing) {
            root.active = playing;
            return;
        }

        root.active = players.length > 0 ? players[0] : null;
    }

    onListChanged: updateActivePlayer()

    Connections {
        target: Mpris
        ignoreUnknownSignals: true
        function onPlayerChanged(player) {
            root.updateActivePlayer();
        }
    }

    function getArtUrl(player) {
        if (!player) return "";
        return player.trackArtUrl ?? "";
    }

    // TỰ ĐỘNG TRIGGER CÀO FILE .LRC CHUẨN XÁC THEO MẢNG ĐẦU TIÊN CỦA INTERNET
    onActiveChanged: {
        if (root.active && root.active.trackTitle) {
            root.currentLyrics = "Searching lyrics...";

            // Lọc sạch toàn bộ các ký tự nhiễu để tránh làm sập câu lệnh Terminal Bash
            let title = String(root.active.trackTitle).replace(/['"()\[\]\-_]/g, " ");
            let artist = String(root.active.trackArtist || "").replace(/['"()\[\]\-_]/g, " ");
            let query = (title + " " + artist).trim();

            // SỬA LỖI QUYẾT ĐỊNH: Sử dụng '.[0].syncedLyrics' của jq để lôi trọn vẹn
            // cấu trúc tệp chứa nhãn giây [00:12.34] của bài hát khớp nhất về máy
            lrcFetcher.command = [
                "bash", "-c",
                "curl -sG --data-urlencode \"q=" + query + "\" \"https://lrclib.net\" | jq -r '.[0].syncedLyrics'"
            ];

            lrcFetcher.running = false;
            lrcFetcher.running = true;
        } else {
            root.currentLyrics = "No track playing";
        }
    }




    // KẾT NỐI LUỒNG HỨNG CHỮ CHO LYRICSFETCHER
    Connections {
        target: lyricsFetcher.stdout
        function onRead(text) {
            let rawData = String(text).trim();
            if (rawData.length > 0 && rawData !== "null") {
                root.currentLyrics = rawData;
            } else {
                root.currentLyrics = "🎵 Instrumental / No lyrics found";
            }
        }
    }

    // ================= BẺ KHÓA LOOP ĐÍCH DANH CHẠY TRÊN LOOPCMD ĐỘC LẬP =================
    function forceToggleLoop() {
        if (!root.active) return;

        let playerIdentity = String(root.active.identity || "").toLowerCase();

        if (playerIdentity.includes("tauon")) {
            root.tauonLoopState = (root.tauonLoopState + 1) % 3;
            let tauonMode = "none";
            if (root.tauonLoopState === 1) tauonMode = "track";
            else if (root.tauonLoopState === 2) tauonMode = "playlist";

            loopCmd.command = ["bash", "-c", "playerctl --player=tauon loop " + tauonMode];
            loopCmd.running = false; loopCmd.running = true;
            return;
        }

        let currentStatus = root.active.loopStatus;
        let nextMode = "none";

        if (currentStatus === 0) nextMode = "track";
        else if (currentStatus === 1) nextMode = "playlist";
        else nextMode = "none";

        // Thực thi bắn lệnh lặp bài riêng biệt, không sợ bị đè chữ
        loopCmd.command = ["bash", "-c", "playerctl --player=" + playerIdentity + " loop " + nextMode];
        loopCmd.running = false; loopCmd.running = true;
    }

    // ================= BẺ KHÓA SHUFFLE CHẠY TRÊN SHUFFLECMD ĐỘC LẬP =================
    function toggleShuffle() {
        if (!root.active) return;

        let playerIdentity = String(root.active.identity || "").toLowerCase();

        if (playerIdentity.includes("tauon")) {
            root.active.shuffle = !root.active.shuffle;
            return;
        }

        shuffleCmd.command = ["bash", "-c", "playerctl --player=" + playerIdentity + " shuffle toggle"];
        shuffleCmd.running = false; shuffleCmd.running = true;
    }

    Component.onCompleted: {
        updateActivePlayer();
    }
}
