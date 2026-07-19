import QtQuick
import QtQuick.Layouts

Item {
    id: root

    implicitWidth: 500
    implicitHeight: 180

    property date now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.now = new Date()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: Qt.formatDateTime(root.now, "hh:mm")

            color: "white"

            font.pixelSize: 82
            font.bold: true

            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: Qt.formatDateTime(root.now, "dddd, dd MMMM yyyy")

            color: "#bbbbbb"

            font.pixelSize: 22

            Layout.alignment: Qt.AlignHCenter
        }
    }
}
