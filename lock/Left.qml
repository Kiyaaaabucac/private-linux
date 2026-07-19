import QtQuick
import QtQuick.Layouts
import "./Left"

Item {
    id: leftRoot

    // ĐÃ SỬA CHÍ MẠNG: Ép độ rộng thực tế cố định để anchors ở file tổng bám vị trí chuẩn xác 100%
    width: 340
    height: 600

    ColumnLayout {
        anchors.fill: parent // Khóa xích ô lưới lọt lòng bên trong vỏ Item
        spacing: 14

        Weather {
            Layout.preferredWidth: 340
            Layout.preferredHeight: 150
            Layout.alignment: Qt.AlignHCenter
        }

        SysInfo {
            Layout.preferredWidth: 340
            Layout.preferredHeight: 250
            Layout.alignment: Qt.AlignHCenter
        }

        Music {
            Layout.preferredWidth: 340
            Layout.preferredHeight: 170
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
