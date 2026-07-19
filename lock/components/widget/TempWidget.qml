import QtQuick
import QtQuick.Layouts
import "../../../../services"

Rectangle {
    Layout.fillWidth: true; Layout.preferredHeight: 80; radius: 14; color: "#161320"
    property real val: (typeof System !== "undefined") ? System.temperature : 0

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 12; spacing: 4
        RowLayout {
            Layout.fillWidth: true
            Text { text: "🌡️  TEMP"; color: "#ff5500"; font.pixelSize: 11; font.bold: true }
            Item { Layout.fillWidth: true }
            Text { text: Math.round(val) + "°C"; color: "white"; font.pixelSize: 14; font.bold: true }
        }
        Item { Layout.fillHeight: true }
        Rectangle {
            Layout.fillWidth: true; height: 4; radius: 2; color: "#33ffffff"
            // Thanh nhiệt độ lấy mốc giới hạn 100°C làm trần tỉ lệ phần trăm
            Rectangle {
                height: parent.height; width: parent.width * (Math.min(val, 100) / 100); radius: 2; color: "#ff5500"
                Behavior on width { NumberAnimation { duration: 250 } }
            }
        }
    }
}
