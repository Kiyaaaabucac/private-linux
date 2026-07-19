import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../services" // ĐÃ SỬA: Lùi 3 tầng chuẩn xác để kết nối tổng đài LockState khi nằm trong components/

Item {
    id: root
    anchors.fill: parent

    z: -1

    // LẮNG NGHE LOCKSTATE: Chỉ kích hoạt luồng đồ họa này khi màn hình khóa bật mở
    visible: typeof LockState !== "undefined" ? LockState.locked : false

    // Sửa dòng số 14 thành đuôi .webp sạch sẽ:
    property string cleanSource: "file:///home/alone/Videos/wallpapers/wallpaper.webp"

    onVisibleChanged: {
        if (visible) {
            // Sửa dòng số 24 (khối giật bộ đệm xả RAM) thành đuôi .webp:
            root.cleanSource = ""
            root.cleanSource = "file:///home/alone/Videos/wallpapers/wallpaper.webp"
            fadeInBackground.restart()
        }
    }


    AnimatedImage {
        id: wallpaper
        source: root.cleanSource
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        playing: root.visible

        cache: false
        asynchronous: true
        opacity: 1.0

        onStatusChanged: {
            if (status === AnimatedImage.Ready) {
                console.log("[BG LOG] Ảnh GIF READY | Kích thước: " + sourceSize.width + "x" + sourceSize.height)
            } else if (status === AnimatedImage.Error) {
                console.log("[BG LOG] LỖI CHÍ MẠNG: Không tìm thấy file !!! Path: " + source)
            }
        }
    }

    FastBlur {
        id: blurEffect
        anchors.fill: parent
        source: wallpaper
        radius: 40
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.60; color: "#15000000" }
            GradientStop { position: 1.0; color: "#99000000" }
        }
    }

    RadialGradient {
        anchors.fill: parent
        horizontalOffset: width / 2; verticalOffset: height / 2
        horizontalRadius: width * 0.75; verticalRadius: height * 0.75
        gradient: Gradient {
            GradientStop { position: 0.50; color: "#00000000" }
            GradientStop { position: 1.0; color: "#AA000000" }
        }
    }

    opacity: 0
    SequentialAnimation on opacity {
        id: fadeInBackground
        running: root.visible
        NumberAnimation { from: 0; to: 1; duration: 350; easing.type: Easing.OutCubic }
    }
}
