import QtQuick
import QtQuick.Layouts
import "../../../../services" // Lùi 5 tầng dấu chấm chọc thẳng sang services cha

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 45
    radius: 10
    color: "#110E1A"

    // Kết nối lắng nghe thời gian thực từ tổng đài System của bạn
    property string downloadSpeed: (typeof System !== "undefined") ? System.netDown : "0 KB/s"
    property string uploadSpeed: (typeof System !== "undefined") ? System.netUp : "0 KB/s"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Tiêu đề dải mạng
        Text {
            text: "↕  NETWORK PIPELINE"
            color: "#9a5b92"
            font.pixelSize: 11
            font.bold: true
        }

        Item { Layout.fillWidth: true }

        // Cụm hiển thị tốc độ Upload / Download đối xứng lộng lẫy chuẩn phong cách PerformanceExpanded
        RowLayout {
            spacing: 14

            // Tốc độ Tải về (Download)
            RowLayout {
                spacing: 4
                Text { text: "📥"; font.pixelSize: 10 }
                Text {
                    text: root.downloadSpeed
                    color: "white"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "JetBrains Mono" // Dùng font Mono để các con số nhảy không bị rung chữ
                }
            }

            // Tốc độ Tải lên (Upload)
            RowLayout {
                spacing: 4
                Text { text: "📤"; font.pixelSize: 10 }
                Text {
                    text: root.uploadSpeed
                    color: "#9a5b92"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "JetBrains Mono"
                }
            }
        }
    }
}
