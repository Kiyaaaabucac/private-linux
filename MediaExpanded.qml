import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import Quickshell.Io
import "../../../../services"

Item {
    id: root
    anchors.fill: parent

    property var player: Players.active
    property real progress: 0
    property var smoothHeights: []
    property real discAngle: 0.0

    Component.onCompleted: {
        let zeroArray = [];
        for (let i = 0; i < 48; i++) zeroArray.push(2);
        root.smoothHeights = zeroArray;
    }

    // =========================================================================================
    // 🎯 ĐỘNG CƠ CÀO LUỒNG NỘI BỘ BIÊN BIÊN: Trỏ thẳng vào file script cava-radial nằm chung thư mục!
    // Sử dụng sh -c bốc chính xác đường dẫn file thực thi cục bộ, giải phóng hoàn toàn lỗi kẹt sandbox Wayland!
    // =========================================================================================
    Process {
        id: localRadialCava
        command: ["sh", "-c", "stdbuf -o0 " + String(Qt.resolvedUrl("./cava-radial")).replace("file://", "")]
        running: false

        stdout: StdioCollector {
            onRead: (data) => {
                let rawText = data.toString().trim();
                let lines = rawText.split("\n");
                let lastValidLine = "";
                for (let idx = lines.length - 1; idx >= 0; idx--) {
                    if (lines[idx].indexOf(";") !== -1) {
                        lastValidLine = lines[idx].trim();
                        break;
                    }
                }
                if (lastValidLine.length > 0) {
                    let parts = lastValidLine.split(";");
                    let tempBars = [];
                    for (let i = 0; i < parts.length; i++) {
                        let txt = parts[i].trim();
                        if (txt.length > 0) {
                            let val = parseInt(txt);
                            tempBars.push(isNaN(val) ? 0 : val);
                        }
                    }
                    if (tempBars.length >= 48) {
                        let smooths = [...root.smoothHeights];
                        for (let j = 0; j < 48; j++) {
                            if (tempBars[j] !== undefined) {
                                smooths[j] = smooths[j] + (tempBars[j] - smooths[j]) * 0.25;
                            }
                        }
                        root.smoothHeights = smooths;
                    }
                }
            }
        }
    }

    // Bộ kích xung nhịp thốc lệnh chu kỳ 16ms (Chuẩn mượt mà 60FPS)
    Timer {
        id: radialCavaPulseTimer
        interval: 16; running: true; repeat: true
        onTriggered: {
            localRadialCava.running = false;
            localRadialCava.running = true;
        }
    }

    Timer {
        interval: 500; running: Players.isPlaying; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (root.player) {
                root.player.positionChanged();
                root.progress = root.player.length > 0 ? Math.min(1.0, Math.max(0.0, root.player.position / root.player.length)) : 0;
            }
        }
    }

    Timer {
        id: discMotorTimer
        interval: 16; running: Players.isPlaying; repeat: true; triggeredOnStart: true
        onTriggered: {
            root.discAngle = (root.discAngle + 0.6) % 360.0;
        }
    }

    function formatTime(sec) {
        if (!sec || sec < 0 || isNaN(sec)) return "0:00";
        let min = Math.floor(sec / 60); let s = Math.floor(sec % 60);
        return min + ":" + (s < 10 ? "0" + s : s);
    }

    // KHUNG CHỨA LAYOUT CHÍNH: Thu hẹp chiều dọc bớt 40px để chừa lề đáy cho Progress Bar nằm biệt lập
    RowLayout {
        width: parent.width
        height: parent.height - 40
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 16

        // KHỐI 1: CAVA VÀ ĐĨA NHẠC (NỚI RỘNG KHÔNG GIAN LÊN 140PX)
        Item {
            id: albumContainer
            Layout.preferredWidth: 140; Layout.fillHeight: true; Layout.alignment: Qt.AlignVCenter
            Item {
                id: radialCavaContainer; anchors.centerIn: parent; width: 110; height: 110
                Repeater {
                    model: 48
                    Item {
                        anchors.fill: parent; transformOrigin: Item.Center; rotation: index * (360 / 48)
                        Rectangle {
                            anchors.bottom: parent.top; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 8; width: 3
                            height: (root.smoothHeights && root.smoothHeights[index] !== undefined) ? Math.max(4, root.smoothHeights[index] * 1.5) : 4;
                            radius: 1.5; color: index % 2 === 0 ? "#ff006a" : "#F5C2E7"; opacity: 0.85
                            Behavior on height { NumberAnimation { duration: 60 } }
                        }
                    }
                }
            }
            Rectangle {
                id: albumBorderCircle; anchors.centerIn: parent; width: 110; height: 110; radius: 55; color: "#1a1625"; border.width: 2; border.color: "#ff006a"; z: 2
                Item {
                    id: rotatingCore; anchors.fill: parent; rotation: root.discAngle
                    Image { id: albumArtSource; anchors.fill: parent; anchors.margins: 3; source: root.player ? Players.getArtUrl(root.player) : ""; fillMode: Image.PreserveAspectCrop; visible: false }
                    Rectangle { id: maskCircle; anchors.fill: parent; anchors.margins: 3; radius: width / 2; visible: false }
                    OpacityMask { anchors.fill: parent; anchors.margins: 3; source: albumArtSource; maskSource: maskCircle; visible: albumArtSource.status === Image.Ready }
                    Text { anchors.centerIn: parent; text: "🎵"; font.pixelSize: 32; visible: albumArtSource.status !== Image.Ready; color: "#F5C2E7" }
                }
            }
        }

        // ================= KHỐI 2: CHI TIẾT TIÊU ĐỀ BÀI HÁT TỐI GIẢN CHUẨN HI-TECH PHẲNG =================
        // Đã trục xuất hoàn toàn Lyrics và thanh Progress Bar cũ ra ngoài để giải phóng không gian thênh thang!
        ColumnLayout {
            id: middleInfoBlock
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: root.player ? root.player.trackTitle || "Unknown Track" : "No Music Playing"; font.pixelSize: 14; font.bold: true; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true; elide: Text.ElideRight }
                Text { text: root.player ? root.player.trackArtist || "Unknown Artist" : ""; font.pixelSize: 11; color: "#F5C2E7"; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true; elide: Text.ElideRight }
            }

            // Tạo khoảng trống mênh mông ở giữa để đẩy các chữ dạt lên thềm trên thoáng mắt
            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            // THANH TIẾN TRÌNH PROGRESS BAR CẢM ỨNG CHUỘT THON GỌN PHẲNG MỊN
            Rectangle {
                id: progressBg
                Layout.fillWidth: true; height: 10; color: "transparent"
                Rectangle {
                    anchors.centerIn: parent; width: parent.width; height: 4; color: "#1d192b"; radius: 2
                    Rectangle { id: progressBarFill; height: parent.height; color: "#ff006a"; radius: 2; width: Math.max(0, Math.floor(parent.width * root.progress)) }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    function seek(mx) { if (root.player && root.player.length > 0) root.player.position = Math.floor(root.player.length * (mx / progressBg.width)) }
                    onPressed: (mouse) => seek(mouse.x)
                    onPositionChanged: (mouse) => { if (pressed) seek(mouse.x) }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text { text: root.player ? root.formatTime(root.player.position) : "0:00"; color: "#ff006a"; font.pixelSize: 10; font.bold: true }
                Item { Layout.fillWidth: true }
                Text { text: root.player ? root.formatTime(root.player.length) : "0:00"; color: "#ffffff"; font.pixelSize: 10; opacity: 0.5 }
            }

            // BỘ NÚT MIXER PHẲNG MẢNH TO RỘNG CHỐNG ẤN HỤT (VÙNG ĐỆM CLICK VÀNG 36x36)
            RowLayout {
                id: controlButtonsRow
                Layout.alignment: Qt.AlignHCenter; spacing: 12

                // 1. SHUFFLE
                Item {
                    width: 36; height: 36; Layout.alignment: Qt.AlignVCenter
                    Text {
                        text: "⇄"; font.pixelSize: 18; font.bold: true; anchors.centerIn: parent
                        color: root.player && root.player.shuffle ? "#ff006a" : "#ffffff"; opacity: root.player && root.player.shuffle ? 1.0 : 0.4
                        Text { text: "•"; font.pixelSize: 14; color: "#ff006a"; visible: root.player && root.player.shuffle; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.bottom; anchors.topMargin: -6 }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { Players.toggleShuffle() } }
                }

                // 2. PREVIOUS
                Item {
                    width: 36; height: 36; Layout.alignment: Qt.AlignVCenter
                    Text { text: "⏮"; font.pixelSize: 15; color: "white"; opacity: 0.8; anchors.centerIn: parent }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if(root.player) root.player.previous() }
                }

                // 3. PLAY/PAUSE
                Item {
                    width: 40; height: 40; Layout.alignment: Qt.AlignVCenter
                    Text { text: Players.isPlaying ? "⏸" : "▶"; font.pixelSize: 20; color: "white"; anchors.centerIn: parent }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if(root.player) root.player.togglePlaying() }
                }

                // 4. NEXT
                Item {
                    width: 36; height: 36; Layout.alignment: Qt.AlignVCenter
                    Text { text: "⏭"; font.pixelSize: 15; color: "white"; opacity: 0.8; anchors.centerIn: parent }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if(root.player) root.player.next() }
                }

                // 5. LOOP
                Item {
                    width: 36; height: 36; Layout.alignment: Qt.AlignVCenter
                    Text {
                        id: loopBtn; text: "↻"; font.pixelSize: 16; font.bold: true; anchors.centerIn: parent
                        readonly property int mode: {
                            if (!root.player) return 0;
                            let isTauon = String(root.player.identity).toLowerCase().includes("tauon");
                            return isTauon ? Players.tauonLoopState : root.player.loopStatus;
                        }
                        color: mode > 0 ? "#ff006a" : "#ffffff"; opacity: mode > 0 ? 1.0 : 0.4
                        Text {
                            text: loopBtn.mode === 1 ? "1" : (loopBtn.mode === 2 ? "•" : "")
                            font.pixelSize: loopBtn.mode === 1 ? 8 : 14; font.bold: true; color: "#ff006a"
                            anchors.left: parent.right; anchors.leftMargin: -2; anchors.bottom: parent.bottom; anchors.bottomMargin: -2
                        }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { Players.forceToggleLoop() } }
                }
            }

            // BỘ CHỌN NGUỒN PHÁT HỆ THỐNG
            RowLayout {
                Layout.alignment: Qt.AlignHCenter; Layout.topMargin: 2
                Rectangle {
                    width: 110; height: 22; radius: 6; color: "#3d1b32"; border.width: 1; border.color: "#ff006a"
                    RowLayout {
                        anchors.centerIn: parent; spacing: 4
                        Text { text: "🎵"; font.pixelSize: 9; color: "#F5C2E7" }
                        Text { text: root.getPlayerName(); font.pixelSize: 9; font.bold: true; color: "white" }
                        Text { text: "▼"; font.pixelSize: 6; color: "#ff006a" }
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let allPlayers = Mpris.players.values;
                            if (allPlayers && allPlayers.length > 1) {
                                let currentIdx = 0;
                                for (let i = 0; i < allPlayers.length; i++) { if (allPlayers[i].busName === root.player.busName) { currentIdx = i; break; } }
                                Players.active = allPlayers[(currentIdx + 1) % allPlayers.length];
                            }
                        }
                    }
                }
            }
        }

        // ================= KHỐI 3: KHUNG CHỨA ẢNH GIF 5TOCGJ DẠT PHẢI =================
        Item {
            Layout.preferredWidth: 200; Layout.preferredHeight: 160; Layout.alignment: Qt.AlignVCenter
            AnimatedImage { id: customDashboardGif; anchors.fill: parent; source: "file:///home/alone/Documents/logos/5tocgj.gif"; fillMode: Image.PreserveAspectFit; playing: Players.isPlaying; visible: status === AnimatedImage.Ready || status === AnimatedImage.Loading }
            Text { anchors.centerIn: parent; text: "🎵"; font.pixelSize: 28; color: "#F5C2E7"; visible: customDashboardGif.status === AnimatedImage.Error }
        }
    }
}
