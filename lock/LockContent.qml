import QtQuick
import QtQuick.Layouts

import "./components"

Item {
    id: root

    LockBackground {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 80

        Item {
            Layout.fillHeight: true
        }

        Clock {
            Layout.alignment: Qt.AlignHCenter
        }

        Music {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 28
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
