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

    implicitWidth: 450
    implicitHeight: 170
    visible: root.player !== null

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

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: Qt.rgba(0, 0, 0, 0.30)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6 // Giảm nhẹ khoảng cách dòng tổng để kéo sát bộ nút lên trên

            // Khối 1: Ảnh bìa album và Thông tin bài hát
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    width: 72; height: 72; radius: 16; clip: true
                    Image {
                        anchors.fill: parent
                        source: root.player ? root.player.trackArtUrl : ""
                        asynchronous: true; cache: false; fillMode: Image.PreserveAspectCrop
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 3
                    Text { Layout.fillWidth: true; text: root.player ? root.player.trackTitle : "No track"; color: "white"; font.pixelSize: 18; font.bold: true; elide: Text.ElideRight }
                    Text { Layout.fillWidth: true; text: root.player ? root.player.trackArtist : ""; color: "#bbbbbb"; font.pixelSize: 13; elide: Text.ElideRight }
                    Text { text: root.player ? root.player.identity : ""; color: "#888888"; font.pixelSize: 11 }
                }
            }

            // Khối 2: Thanh tiến trình Progress Bar
            Rectangle {
                Layout.fillWidth: true; height: 6; radius: 3; color: "#33ffffff"
                Rectangle {
                    id: progressFill
                    height: parent.height; width: parent.width * root.progress; radius: 3; color: AlbumColors.primary
                    Behavior on width { NumberAnimation { duration: 180 } }
                }
                MouseArea {
                    anchors.fill: parent
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

            // Khối 3: Bộ đếm giây chạy nhạc
            RowLayout {
                Layout.fillWidth: true
                Text { color: "#bbbbbb"; font.pixelSize: 11; text: root.format(root.currentPosition) }
                Item { Layout.fillWidth: true }
                Text { color: "#bbbbbb"; font.pixelSize: 11; text: root.player ? root.format(root.player.length) : "0:00" }
            }

            // ĐỘT PHÁ: Lò xo cao su tự động nén dạt, đẩy bộ nút bấm xếch lên trên sát hàng thời gian nhạc
            Item {
                Layout.fillHeight: true
            }

            // Khối 4: BỘ NÚT ĐIỀU KHIỂN ICON TEXT PHẲNG (ĐÃ SỬA CÚ PHÁP AN TOÀN)
            RowLayout {
                id: controlButtonsRow
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -10 // Thay thế anchors.topMargin lỗi bằng Layout.topMargin chuẩn ô lưới
                spacing: 36

                // Nút PREV
                Text {
                    text: "⏮"
                    font.pixelSize: 22
                    color: "white"
                    opacity: btnPrevMouse.containsMouse ? 1.0 : 0.85

                    MouseArea {
                        id: btnPrevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.player) root.player.previous()
                    }
                }

                // Nút PLAY / PAUSE
                Text {
                    text: Players.isPlaying ? "⏸" : "▶"
                    font.pixelSize: 24
                    color: "white"
                    opacity: btnPlayMouse.containsMouse ? 1.0 : 0.9

                    MouseArea {
                        id: btnPlayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.player) root.player.togglePlaying()
                    }
                }

                // Nút NEXT
                Text {
                    text: "⏭"
                    font.pixelSize: 22
                    color: "white"
                    opacity: btnNextMouse.containsMouse ? 1.0 : 0.85

                    MouseArea {
                        id: btnNextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (root.player) root.player.next()
                    }
                }
            }
        }
    }
}
