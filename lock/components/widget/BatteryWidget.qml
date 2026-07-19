import QtQuick
import QtQuick.Layouts
import "../../../../services"

Rectangle {
    Layout.fillWidth: true; Layout.preferredHeight: 80; radius: 14; color: "#161320"
    property var bat: (typeof System !== "undefined") ? System.battery : null
    property real val: bat ? Math.round(bat.percentage * 100) : 0
    property bool chg: bat ? bat.isCharging : false

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 12; spacing: 4
        RowLayout {
            Layout.fillWidth: true
            Text { text: chg ? "⚡ CHARGING" : "🔋 BATTERY"; color: chg ? "#00ff66" : "#ffcc00"; font.pixelSize: 11; font.bold: true }
            Item { Layout.fillWidth: true }
            Text { text: val + "%"; color: "white"; font.pixelSize: 14; font.bold: true }
        }
        Item { Layout.fillHeight: true }
        Rectangle {
            Layout.fillWidth: true; height: 4; radius: 2; color: "#33ffffff"
            Rectangle {
                height: parent.height; width: parent.width * (val / 100); radius: 2; color: chg ? "#00ff66" : "#ffcc00"
                Behavior on width { NumberAnimation { duration: 250 } }
            }
        }
    }
}
