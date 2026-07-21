import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import "../../../services"

Item {
    id: root

    // Tự động kéo giãn 100% lấp đầy lòng chiều dọc của ô GlassCard vế phải
    anchors.fill: parent

    property var player: Players.active
    property real progress: 0

    Timer {
        interval: 500
        running: Players.isPlaying
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.player) {
                root.player.positionChanged();

                let pos = root.player.position;
                let len = root.player.length;

                if (len > 0) {
                    root.progress = Math.min(1.0, Math.max(0.0, pos / len));
                } else {
                    root.progress = 0;
                }
            }
        }
    }

    function title() { return root.player ? root.player.trackTitle || "Unknown title" : "No music" }
    function artist() { return root.player ? root.player.trackArtist || "Unknown artist" : "Unknown artist" }
    function cover() { return root.player ? Players.getArtUrl(root.player) : "" }

    function formatTime(sec) {
        if (!sec || sec < 0 || isNaN(sec)) return "0:00";
        let min = Math.floor(sec / 60);
        let s = Math.floor(sec % 60);
        return min + ":" + (s < 10 ? "0" + s : s);
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ================= NỬA TRÊN: ĐĨA NHẠC TRÒN XOE CÂN TÂM (130x130) =================
        Rectangle {
            id: albumBorderCircle
            Layout.preferredWidth: 130
            Layout.preferredHeight: 130
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            radius: width / 2
            color: "#1a1625"
            border.width: 2
            border.color: "#ff006a"

            Image {
                id: albumArtSource
                anchors.fill: parent
                anchors.margins: 4
                source: root.cover()
                fillMode: Image.PreserveAspectCrop
                visible: false
                asynchronous: true
                cache: true
            }

            Rectangle {
                id: maskCircle
                anchors.fill: parent
                anchors.margins: 4
                radius: width / 2
                visible: false
            }

            OpacityMask {
                anchors.fill: parent
                anchors.margins: 4
                source: albumArtSource
                maskSource: maskCircle
                visible: root.cover() !== ""
            }

            Text {
                anchors.centerIn: parent
                text: "🎵"
                font.pixelSize: 42
                visible: root.cover() === ""
                color: "#F5C2E7"
            }
        }

        // ================= NỬA DƯỚI: THÔNG TIN BÀI HÁT & THANH TUA CHUỘT THÔNG MINH =================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "🎵 Vinnahouse Box"
                color: "#F5C2E7"
                font.pixelSize: 12
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.title()
                color: "white"
                font.pixelSize: 15
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.artist()
                color: "white"
                font.pixelSize: 11
                elide: Text.ElideRight
                opacity: 0.7
            }

            Item {
                Layout.fillHeight: true
            }

            // SỬA ĐỔI CỐT LÕI: Thanh Progress Bar bọc MouseArea để click/kéo tua nhạc thời gian thực
            Rectangle {
                id: progressBg
                Layout.fillWidth: true
                height: 12 // Tăng nhẹ diện tích vùng bọc ẩn để ngón tay và chuột dễ click trúng viền
                color: "transparent" // Làm hộp bọc vô hình bên ngoài

                // Thanh nền tối thực tế ở bên trong
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: 4 // Giữ nguyên độ mảnh 4px hi-tech
                    radius: 2
                    color: "#3d1b32"

                    Rectangle {
                        id: progressFill
                        height: parent.height
                        radius: 2
                        width: Math.max(0, Math.floor(parent.width * root.progress))
                        color: "#ff006a"

                        Behavior on width {
                            // Tự động tắt Animation khi đang kéo chuột tua để tránh bị khựng giật thanh bar
                            enabled: !progressBarMouseArea.pressed
                            NumberAnimation { duration: 150 }
                        }
                    }
                }

                // CƠ CHẾ TUA NHẠC CHUẨN XÁC QUA ĐƯỜNG TRUYỀN MPRIS D-BUS
                MouseArea {
                    id: progressBarMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    function seekMusic(mouseX) {
                        if (root.player && root.player.length > 0) {
                            // Tính toán tỷ lệ phần trăm vị trí chuột click theo trục ngang X
                            let ratio = Math.min(1.0, Math.max(0.0, mouseX / progressBg.width));
                            let newPosition = Math.floor(root.player.length * ratio);

                            // Ghi trực tiếp giá trị thời gian vị trí mới vào player hệ thống
                            root.player.position = newPosition;
                            root.progress = ratio;
                        }
                    }

                    // Kích hoạt tua khi vừa click nhấn chuột xuống hoặc bấm giữ rê đi rê lại (Drag)
                    onPressed: (mouse) => seekMusic(mouse.x)
                    onPositionChanged: (mouse) => { if (pressed) seekMusic(mouse.x) }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.player ? root.formatTime(root.player.position) : "0:00"
                    color: "white"
                    font.pixelSize: 10
                    opacity: 0.6
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: root.player ? root.formatTime(root.player.length) : "0:00"
                    color: "white"
                    font.pixelSize: 10
                    opacity: 0.6
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 24

                Text {
                    text: "⏮"
                    font.pixelSize: 22
                    color: "white"
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { if(root.player?.canGoPrevious) root.player.previous() }
                    }
                }

                Item {
                    width: 32
                    height: 32
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: Players.isPlaying ? "⏸" : "▶"
                        font.pixelSize: 26
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { if(root.player?.canTogglePlaying) root.player.togglePlaying() }
                    }
                }

                Text {
                    text: "⏭"
                    font.pixelSize: 22
                    color: "white"
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { if(root.player?.canGoNext) root.player.next() }
                    }
                }
            }
        }
    }
}
