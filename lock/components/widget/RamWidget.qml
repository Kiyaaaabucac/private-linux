import QtQuick
import QtQuick.Layouts
import "../../../../services"

Rectangle {
    Layout.fillWidth: true; Layout.preferredHeight: 80; radius: 14; color: "#161320"
    property real val: (typeof System !== "undefined") ? System.ramUsage : 0

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 12; spacing: 4
        RowLayout {
            Layout.fillWidth: true
            Text { text: "🧠  RAM"; color: "#00f0ff"; font.pixelSize: 11; font.bold: true }
            Item { Layout.fillWidth: true }
            Text { text: Math.round(val) + "%"; color: "white"; font.pixelSize: 14; font.bold: true }
        }
        Item { Layout.fillHeight: true }
        Rectangle {
            Layout.fillWidth: true; height: 4; radius: 2; color: "#33ffffff"
            Rectangle {
                height: parent.height; width: parent.width * (val / 100); radius: 2; color: "#00f0ff"
                Behavior on width { NumberAnimation { duration: 250 } }
            }
        }
    }
}
