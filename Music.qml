import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import "../../../services"

Item {
    id: root
    property var player: Players.active
    property real progress: 0
    property real currentPosition: 0

    // Khóa cứng kích thước hình học chuẩn của khối nhạc ở vách trái của bạn
    implicitWidth: 340
    implicitHeight: 170

    // 🔥 CHÍ MẠNG: Khai tử hoàn toàn dòng visible cũ!
    // Luôn luôn mở thông suốt để nhường trọn quyền ẩn hiện cho file cha Left.qml điều phối nhịp domino! [1.1]
    visible: true

    onVisibleChanged: {
        if (visible) {
            positionTimer.restart()
        }
    }

    Timer {
        id: positionTimer
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!root.player) {
                root.currentPosition = 0
                root.progress = 0
                return
            }

            let pos = Number(root.player.position)
            let len = Number(root.player.length)

            if (isNaN(pos) || pos < 0) pos = 0
                if (isNaN(len) || len <= 0) len = 0

                    root.currentPosition = pos
                    root.progress = len > 0 ? Math.min(1, Math.max(0, pos / len)) : 0
        }
    }

    Connections {
        target: Players
        ignoreUnknownSignals: true
        function onActiveChanged() {
            root.player = Players.active
            root.currentPosition = 0
            root.progress = 0
        }
    }

    function format(sec) {
        if (isNaN(sec) || sec < 0) return "0:00"
            let totalSeconds = Math.floor(sec)
            let min = Math.floor(totalSeconds / 60)
            let s = totalSeconds % 60
            return min + ":" + ("0" + s).slice(-2)
    }

    // BỆ ĐỠ TỔNG: Hộp kính mờ đồng bộ dải màu sâu thẳm 45% bóng đêm [1.1]
    Rectangle {
        anchors.fill: parent
        radius: 22
        color: Qt.rgba(11 / 255, 9 / 255, 17 / 255, 0.45)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6

            // =========================================================================
            // 🖼️ KHỐI 1: ẢNH BÌA ALBUM VÀ THÔNG TIN BÀI HÁT (TÍCH HỢP TRẠNG THÁI TRỐNG) [1.1]
            // =========================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    width: 64 // Tinh chỉnh kích thước 64x64 vuông vức cân đối đồ họa [1.1]
                    height: 64
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.03)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.05)
                    clip: true

                    Image {
                        id: albumArtImage
                        anchors.fill: parent
                        // Nếu có nhạc thì bốc ảnh bìa, không có thì trỏ chuỗi rỗng sạch sẽ [1.1]
                        source: (root.player && root.player.trackArtUrl) ? root.player.trackArtUrl : ""
                        asynchronous: true
                        cache: false
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true

                        // 🎯 TRẠNG THÁI DỰ PHÒNG: Biểu tượng đĩa nhạc Cyberpunk phát sáng khi trống nhạc [1.1]
                        Rectangle {
                            anchors.fill: parent
                            color: "#161320"
                            visible: albumArtImage.status !== Image.Ready

                            Text {
                                anchors.centerIn: parent
                                text: "🎵"
                                font.pixelSize: 22
                                opacity: 0.3
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    // Tên Bài Hát: Trống nhạc tự động báo chữ phẳng tinh khiết [1.1]
                    Text {
                        Layout.fillWidth: true
                        text: (root.player && root.player.trackTitle) ? root.player.trackTitle : "No track playing"
                        color: (root.player && root.player.trackTitle) ? "white" : "#A6ADC8"
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "JetBrains Mono"
                        elide: Text.ElideRight
                        style: Text.Normal
                        opacity: (root.player && root.player.trackTitle) ? 1.0 : 0.45 // Không nhạc tự động mờ dịu mắt [1.1]
                    }

                    // Tên Ca Sĩ
                    Text {
                        Layout.fillWidth: true
                        text: (root.player && root.player.trackArtist) ? root.player.trackArtist : "Standby Session"
                        color: "#C3BAC6"
                        font.pixelSize: 11
                        font.family: "JetBrains Mono"
                        elide: Text.ElideRight
                        style: Text.Normal
                        opacity: (root.player && root.player.trackArtist) ? 0.7 : 0.3
                    }

                    // Định danh nguồn phát (Spotify, Tauon...)
                    Text {
                        text: (root.player && root.player.identity) ? String(root.player.identity).toUpperCase() : "MPRIS DOCK"
                        color: "#ff006a" // Đậm đà bản sắc hồng Neon của bro [1.1]
                        font.pixelSize: 9
                        font.bold: true
                        font.family: "JetBrains Mono"
                        style: Text.Normal
                        opacity: (root.player && root.player.identity) ? 0.8 : 0.25
                    }
                }
            }

            // =========================================================================
            // 📊 KHỐI 2: THANH TIẾN TRÌNH PROGRESS BAR
            // =========================================================================
            Rectangle {
                Layout.fillWidth: true
                height: 4 // Tối giản vạch dày 6px xuống 4px cho phẳng mịn hi-tech [1.1]
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.06)

                Rectangle {
                    id: progressFill
                    height: parent.height
                    width: parent.width * root.progress
                    radius: 2
                    // Nếu dải màu AlbumColors rỗng, tự động lót dải màu hồng Neon chói lọi của bạn [1.1]
                    color: (typeof AlbumColors !== "undefined" && AlbumColors.primary) ? AlbumColors.primary : "#ff006a"

                    Behavior on width { NumberAnimation { duration: 180 } }
                }

                MouseArea {
                    anchors.fill: parent
                    // Vô hiệu hóa kéo trượt khi trống nhạc để chống lỗi gãy số [1.1]
                    enabled: root.player !== null
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                    function seek(mouse) {
                        if (!root.player || root.player.length <= 0) return
                            let value = Math.max(0, Math.min(1, mouse.x / width))
                            root.progress = value
                            root.player.position = root.player.length * value
                    }
                    onPressed: seek(mouse)
                    onPositionChanged: if (mouse.buttons) seek(mouse)
                }
            }

            // =========================================================================
            // 📊 KHỐI 3: BỘ ĐẾM GIÂY CHẠY NHẠC
            // =========================================================================
            RowLayout {
                Layout.fillWidth: true
                Text { color: "#A6ADC8"; opacity: 0.6; font.pixelSize: 10; font.family: "JetBrains Mono"; text: root.format(root.currentPosition) }
                Item { Layout.fillWidth: true }
                Text { color: "#A6ADC8"; opacity: 0.6; font.pixelSize: 10; font.family: "JetBrains Mono"; text: root.player ? root.format(root.player.length) : "0:00" }
            }

            // Lò xo cao su tự động nén dạt, ghim chặt bộ điều khiển vuông vức [1.1]
            Item { Layout.fillHeight: true }

            // =========================================================================
            // 📊 KHỐI 4: BỘ NÚT ĐIỀU KHIỂN ĐA TRẠNG THÁI (ĐÃ SỬA SẠCH LỖI DỒN DÒNG)
            // =========================================================================
            RowLayout {
                id: controlButtonsRow
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -6
                spacing: 40

                // NÚT 1: PREVIOUS (TUA LÙI)
                Text {
                    text: "⏮"
                    font.pixelSize: 20
                    color: (root.player && btnPrevMouse.containsMouse) ? "#ff006a" : "white"
                    opacity: root.player ? (btnPrevMouse.containsMouse ? 1.0 : 0.7) : 0.2
                    font.family: "JetBrainsMono Nerd Font"
                    style: Text.Normal

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    MouseArea {
                        id: btnPrevMouse
                        anchors.fill: parent
                        enabled: root.player !== null
                        hoverEnabled: enabled
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (root.player) {
                                root.player.previous()
                            }
                        }
                    }
                }

                // NÚT 2: PLAY / PAUSE (TẠM DỪNG / PHÁT CHÍNH)
                Text {
                    text: root.player ? (Players.isPlaying ? "⏸" : "▶") : "▶"
                    font.pixelSize: 22
                    color: (root.player && btnPlayMouse.containsMouse) ? "#ff006a" : "white"
                    opacity: root.player ? (btnPlayMouse.containsMouse ? 1.0 : 0.8) : 0.2
                    font.family: "JetBrainsMono Nerd Font"
                    style: Text.Normal

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    MouseArea {
                        id: btnPlayMouse
                        anchors.fill: parent
                        enabled: root.player !== null
                        hoverEnabled: enabled
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (root.player) {
                                root.player.togglePlaying()
                            }
                        }
                    }
                }

                // NÚT 3: NEXT (TUA TIẾP)
                Text {
                    text: "⏭"
                    font.pixelSize: 20
                    color: (root.player && btnNextMouse.containsMouse) ? "#ff006a" : "white"
                    opacity: root.player ? (btnNextMouse.containsMouse ? 1.0 : 0.7) : 0.2
                    font.family: "JetBrainsMono Nerd Font"
                    style: Text.Normal

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    MouseArea {
                        id: btnNextMouse
                        anchors.fill: parent
                        enabled: root.player !== null
                        hoverEnabled: enabled
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (root.player) {
                                root.player.next()
                            }
                        }
                    }
                }
            }
        } // <-- Chốt đóng thẻ ColumnLayout tổng
    } // <-- Chốt đóng thẻ Rectangle bệ đỡ
} // <-- Chốt đóng toàn bộ file gốc Item ngoài cùng (root) của bạn
