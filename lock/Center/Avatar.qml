import QtQuick


Item {

    id: avatarRoot

    implicitWidth: 140
    implicitHeight: 140

    property string avatarPath:
    "file:///home/alone/Documents/logos/avatar.png"


    Rectangle {

        id: avatarFrame

        anchors.fill: parent

        radius: width / 2

        color: Qt.rgba(0,0,0,0.35)

        border.width: 2
        border.color: "#ff006a"

        clip: true


        Image {

            id: userImage

            anchors.fill: parent

            source: avatarRoot.avatarPath

            fillMode: Image.PreserveAspectCrop

            asynchronous: true

            cache: false

        }


        Text {

            anchors.centerIn: parent

            visible: userImage.status !== Image.Ready

            text: "👤"

            font.pixelSize: 48
        }
    }


    Rectangle {

        anchors.fill: parent

        radius: width / 2

        color: "transparent"

        border.width: 3

        border.color: Qt.rgba(1,0,0.4,0.35)

        z: -1
    }
}
