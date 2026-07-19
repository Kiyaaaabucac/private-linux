import QtQuick
import "./components"
import "."

Item {

    id: lockContentRoot

    anchors.fill: parent


    // ==============================
    // PAM BRIDGE
    // ==============================
    function findChildPam() {
        return centerPanel.findChildPam()
    }


    // ==============================
    // Dynamic Island
    // ==============================
    DynamicIsland {
        id: island

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 10
        }

        z: 100
    }


    // ==============================
    // Left
    // ==============================
    Left {
        id: leftPanel

        anchors {
            left: parent.left
            leftMargin: 400
            verticalCenter: parent.verticalCenter
        }
    }


    // ==============================
    // Center
    // ==============================
    Center {
        id: centerPanel

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -20
        }
    }


    // ==============================
    // Right
    // ==============================
    Right {
        id: rightPanel

        anchors {
            right: parent.right
            rightMargin: 400
            verticalCenter: parent.verticalCenter
        }
    }
}
