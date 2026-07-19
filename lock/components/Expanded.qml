import QtQuick
import QtQuick.Layouts

// CHÍ MẠNG: Khai báo quét thư mục con "widget" cùng cấp bằng dấu chấm phẳng sạch sẽ
import "./widget" as IslandWidgets

Rectangle {
    id: expandedView
    anchors.fill: parent
    radius: 24
    color: "#F20D0D11" // Đen sâu thẳm phẳng lỳ, độ mờ 95% chuẩn Caelestia Shell
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.08)

    GridLayout {
        anchors.fill: parent
        anchors.margins: 18
        columns: 3
        rowSpacing: 16
        columnSpacing: 16

        // HÀNG 1: VI XỬ LÝ & NHIỆT ĐỘ CORE
        IslandWidgets.CpuWidget {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
        }
        IslandWidgets.GpuWidget {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
        }
        IslandWidgets.TempWidget {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
        }

        // HÀNG 2: BỘ NHỚ LƯU TRỮ & NĂNG LƯỢNG
        IslandWidgets.RamWidget {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
        }
        IslandWidgets.DiskWidget {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
        }
        IslandWidgets.BatteryWidget {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
        }

        // HÀNG CỐ ĐỊNH ĐÁY: DẢI THÔNG BÁO MẠNG BĂNG THÔNG RỘNG
        IslandWidgets.NetworkWidget {
            Layout.fillWidth: true
            Layout.columnSpan: 3
            Layout.preferredHeight: 45
        }
    }
}
