import QtQuick
import QtQuick.Layouts
// 🎯 SỬA LỖI CHÍ MẠNG DÒNG 3: Thêm số 5 vào giữa để nạp đúng thư viện hiệu ứng đồ họa của Qt6!
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import Quickshell.Io
import "../../../../services"


Item {
    id: root

    anchors.fill: parent

    property var player: Players.active
    property real progress: 0

    // MẢNG DỮ LIỆU SÓNG THẬT: Đồng bộ 48 vạch tần số chạy quanh đĩa nhạc
    property var smoothHeights: []

    property real discAngle: 0.0

    Component.onCompleted: {
        let zeroArray = [];
        for (let i = 0; i < 48; i++) zeroArray.push(2);
        root.smoothHeights = zeroArray;
    }

    // =========================================================================================
    // 🎯 ĐỘNG CƠ CÀO LUỒNG NỘI BỘ BIÊN BIÊN: Trỏ thẳng vào file script nằm chung một thư mục!
    // Gỡ bỏ hoàn toàn running: true lỗi, mượn sh -c kích nổ liên tục loang loáng mượt mà 60FPS!
    // =========================================================================================
    Process {
        id: localRadialCava
        // 🎯 GIẢI PHÁP ĐẮT GIÁ: Dùng sh -c bốc chính xác file script nằm cùng thư mục thông qua vị trí hiện tại của file QML!
        command: ["sh", "-c", "stdbuf -o0 " + String(Qt.resolvedUrl("./cava-radial")).replace("file://", "")]

        // Khóa chết nguồn false để nhường toàn quyền kích nổ chu kỳ cho Timer xoay vòng
        running: false

        stdout: StdioCollector {
            onRead: (data) => {
                let rawText = data.toString().trim();
                let lines = rawText.split("\n");

                // Quét ngược tìm dòng chứa chuỗi số CAVA mới nhất có dấu chấm phẩy
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

                    // Màng lọc ma trận loại bỏ sạch sành sanh các chuỗi rỗng đầu/cuối
                    for (let i = 0; i < parts.length; i++) {
                        let txt = parts[i].trim();
                        if (txt.length > 0) {
                            let val = parseInt(txt);
                            tempBars.push(isNaN(val) ? 0 : val);
                        }
                    }

                    // Nẹp cứng ma trận: Đủ mảng 48 vạch tần số mới đẩy lên dải Repeater quay tròn
                    if (tempBars.length >= 48) {
                        let smooths = [...root.smoothHeights];
                        for (let j = 0; j < 48; j++) {
                            if (tempBars[j] !== undefined) {
                                // Hệ số quán tính lò xo 0.25 nhún nhảy mịn màng mượt mà 60FPS+
                                smooths[j] = smooths[j] + (tempBars[j] - smooths[j]) * 0.25;
                            }
                        }
                        root.smoothHeights = smooths;
                    }
                }
            }
        }
    }

    // 🎯 BỘ KÍCH XUNG NHỊP THỐC LUỒNG 60FPS
    Timer {
        id: radialCavaPulseTimer
        interval: 16
        running: true
        repeat: true
        onTriggered: {
            localRadialCava.running = false;
            localRadialCava.running = true;
        }
    }




    // 2. TIMER TIẾN TRÌNH PROGRESS BAR
    Timer {
        interval: 500
        running: Players.isPlaying; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (root.player) {
                root.player.positionChanged();
                root.progress = root.player.length > 0 ? Math.min(1.0, Math.max(0.0, root.player.position / root.player.length)) : 0;
            }
        }
    }

    // 3. TIMER ĐỘNG CƠ ĐĨA XOAY 60FPS
    Timer {
        id: discMotorTimer
        interval: 16; running: Players.isPlaying; repeat: true; triggeredOnStart: true
        onTriggered: {
            root.discAngle = (root.discAngle + 0.6) % 360.0;
        }
    }

    function getPlayerName() {
        if (!root.player) return "No Player";
        let identity = String(root.player.identity || "").trim();
        return identity.length > 0 ? identity.charAt(0).toUpperCase() + identity.slice(1) : "Media Player";
    }

    function formatTime(sec) {
        if (!sec || sec < 0 || isNaN(sec)) return "0:00";
        let min = Math.floor(sec / 60); let s = Math.floor(sec % 60);
        return min + ":" + (s < 10 ? "0" + s : s);
    }

    RowLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 20

        // ================= KHỐI 1: ĐĨA TRÒN VÀ VÒNG SÓNG CAVA PHÓNG ĐẠI KÍCH THƯỚC =================
        Item {
            id: albumContainer; Layout.preferredWidth: 120; Layout.fillHeight: true; Layout.alignment: Qt.AlignVCenter

            Item {
                id: radialCavaContainer; anchors.centerIn: parent; width: 110; height: 110
                Repeater {
                    model: 48
                    Item {
                        anchors.fill: parent; transformOrigin: Item.Center; rotation: index * (360 / 48)
                        Rectangle {
                            anchors.bottom: parent.top;
                            anchors.horizontalCenter: parent.horizontalCenter;

                            // 🎯 NỚI RỘNG KHOẢNG ĐỆM: Đẩy chân vạch sóng lùi xa rìa viền đĩa 4px cho thoáng hẳn ra ngoài!
                            anchors.bottomMargin: 4;
                            width: 3;

                            // 🎯 TOÁN HỌC PHÓNG ĐẠI CHIỀU CAO VÀNG: Nhân thêm 1.5 lần biên độ thô để cột sóng vọt dài lên tới 55px,
                            // bung tràn lộng lẫy ra ngoài lớp kính viền đĩa nhạc, không bao giờ bị che khuất nữa!
                            height: root.smoothHeights[index] !== undefined ? Math.max(2, root.smoothHeights[index] * 1.5) : 2;

                            radius: 1.5;
                            color: index % 2 === 0 ? "#ff006a" : "#F5C2E7";
                            opacity: Players.isPlaying ? 0.95 : 0.25

                            Behavior on height { NumberAnimation { duration: 60 } }
                        }
                    }
                }
            }

            Rectangle {
                id: albumBorderCircle; anchors.centerIn: parent; width: 110; height: 110; radius: 55; color: "#1a1625"; border.width: 2; border.color: "#ff006a"; z: 2

                Item {
                    id: rotatingCore
                    anchors.fill: parent
                    rotation: root.discAngle

                    Image { id: albumArtSource; anchors.fill: parent; anchors.margins: 3; source: root.player ? Players.getArtUrl(root.player) : ""; fillMode: Image.PreserveAspectCrop; visible: false }
                    Rectangle { id: maskCircle; anchors.fill: parent; anchors.margins: 3; radius: width / 2; visible: false }
                    OpacityMask { anchors.fill: parent; anchors.margins: 3; source: albumArtSource; maskSource: maskCircle; visible: albumArtSource.status === Image.Ready }
                    Text { anchors.centerIn: parent; text: "🎵"; font.pixelSize: 32; visible: albumArtSource.status !== Image.Ready; color: "#F5C2E7" }
                }
            }
        }


        // ================= KHỐI 2: CHI TIẾT BÀI HÁT TỐI GIẢN CHUẨN HI-TECH =================
        ColumnLayout {
            id: middleInfoBlock
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.alignment: Qt.AlignVCenter; spacing: 4

            ColumnLayout {
                Layout.fillWidth: true; spacing: 1
                Text { text: root.player ? root.player.trackTitle || "Unknown Track" : "No Music Playing"; font.pixelSize: 13; font.bold: true; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true; elide: Text.ElideRight }
                Text { text: root.player ? root.player.trackArtist || "Unknown Artist" : ""; font.pixelSize: 10; color: "#F5C2E7"; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true; elide: Text.ElideRight }
            }

            ColumnLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 75; spacing: 2; Layout.alignment: Qt.AlignHCenter
                Text { text: "•  •  •  •  •  •  •  •  •  •  •  •  •  •  •"; color: "#ffffff"; opacity: 0.12; font.pixelSize: 9; Layout.alignment: Qt.AlignHCenter }
                Text {
                    text: root.player ? "💿 Album: " + (root.player.trackAlbum || "Single Track") : "Waiting for audio pipeline..."
                    color: "#ff006a"; font.pixelSize: 11; font.bold: true; Layout.alignment: Qt.AlignHCenter; elide: Text.ElideRight; Layout.maximumWidth: 240
                }
                Text { text: "✨ Audio Pipeline Status: Synced"; color: "#ffffff"; opacity: 0.35; font.pixelSize: 9; Layout.alignment: Qt.AlignHCenter }
                Text { text: "•  •  •  •  •  •  •  •  •  •  •  •  •  •  •"; color: "#ffffff"; opacity: 0.12; font.pixelSize: 9; Layout.alignment: Qt.AlignHCenter }
            }

            // THANH TIẾN TRÌNH TUA NHẠC CẢM ỨNG CHUỘT
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
                Text { text: root.player ? root.formatTime(root.player.position) : "0:00"; color: "#ff006a"; font.pixelSize: 9 }
                Item { Layout.fillWidth: true }
                Text { text: root.player ? root.formatTime(root.player.length) : "0:00"; color: "#ffffff"; font.pixelSize: 9; opacity: 0.5 }
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
            Layout.preferredWidth: 140; Layout.preferredHeight: 110; Layout.alignment: Qt.AlignVCenter
            AnimatedImage { id: customDashboardGif; anchors.fill: parent; source: "file:///home/alone/Documents/logos/5tocgj.gif"; fillMode: Image.PreserveAspectFit; playing: Players.isPlaying; visible: status === AnimatedImage.Ready || status === AnimatedImage.Loading }
            Text { anchors.centerIn: parent; text: "🎵"; font.pixelSize: 28; color: "#F5C2E7"; visible: customDashboardGif.status === AnimatedImage.Error }
        }
    }
}
