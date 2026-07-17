import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Mpris
import "../../services"

Item {
    id: root
    property var player: Players.active
    property real progress: 0
    property real currentPosition: 0
    implicitWidth: 450
    implicitHeight: 170
    visible: root.player !== null

    // SỬA LỖI LOCKSCREEN: Tự động đánh thức Timer và cập nhật thời gian ngay khi màn hình khóa hiển thị
    onVisibleChanged: {
        if (visible) {
            positionTimer.restart()
            updateProgress()
        }
    }

    function updateProgress() {
        if (!root.player) { root.currentPosition = 0; root.progress = 0; return }

        // Gọi làm mới thời gian an toàn tránh lỗi crash IPC của Lockscreen
        try { root.player.positionChanged() } catch(e) {}

        let pos = Number(root.player.position)
        let len = Number(root.player.length)
        if (isNaN(pos)) pos = 0
            if (isNaN(len) || len <= 0) { root.currentPosition = pos; root.progress = 0; return }
            root.currentPosition = pos
            root.progress = Math.min(1, Math.max(0, pos / len))
    }

    Timer {
        id: positionTimer
        interval: 500
        running: root.visible // Chỉ chạy khi widget đang hiển thị trên màn hình khóa
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateProgress()
    }

    Connections {
        target: Players
        ignoreUnknownSignals: true
        function onActiveChanged() {
            root.player = Players.active
            root.currentPosition = 0
            root.progress = 0
            positionTimer.restart() // Khởi động lại vòng lặp cho player mới
        }
    }

    // Sửa Connections động: Theo dõi chính xác bài hát thay đổi của player hiện tại
    Connections {
        target: root
        ignoreUnknownSignals: true
        function onPlayerChanged() {
            if (root.player) {
                root.player.trackTitleChanged.disconnect(root.resetTrackTime)
                root.player.trackTitleChanged.connect(root.resetTrackTime)
            }
        }
    }

    function resetTrackTime() { root.currentPosition = 0; root.progress = 0 }

    // Tính toán chuẩn theo đơn vị micro giây (MPRIS chuẩn Linux)
    function format(us) {
        if (isNaN(us) || us < 0) return "0:00"
            let sec = Math.floor(us / 1000000)
            let min = Math.floor(sec / 60)
            let s = sec % 60
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
            spacing: 10

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

            Rectangle {
                id: progressBg
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
                            root.player.position = Math.floor(root.player.length * value)
                    }
                    onPressed: seek(mouse)
                    onPositionChanged: if (mouse.buttons) seek(mouse)
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text { color: "#bbbbbb"; font.pixelSize: 11; text: root.format(root.currentPosition) }
                Item { Layout.fillWidth: true }
                Text { color: "#bbbbbb"; font.pixelSize: 11; text: root.player ? root.format(root.player.length) : "0:00" }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter; spacing: 24
                Button {
                    text: "⏮"; onClicked: if (root.player) root.player.previous()
                    background: Rectangle { color: "transparent" }
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Button {
                    text: Players.isPlaying ? "⏸" : "▶"
                    onClicked: if (root.player) root.player.togglePlaying()
                    background: Rectangle { color: "transparent" }
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 22; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Button {
                    text: "⏭"; onClicked: if (root.player) root.player.next()
                    background: Rectangle { color: "transparent" }
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
        }
    }
}
