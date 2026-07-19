import QtQuick
import QtQuick.Layouts
import "./Right"

Item {
    id: rightRoot

    width: 340
    height: 600

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Calendar {
            Layout.fillWidth: true
            Layout.preferredHeight: 360
        }

        NotifDock {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
