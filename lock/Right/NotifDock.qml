import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications


Item {
    id: notifRoot

    implicitWidth: 340
    implicitHeight: 400


    Rectangle {

        anchors.fill: parent

        radius: 22

        color: Qt.rgba(0,0,0,0.30)

        border.width: 1
        border.color: Qt.rgba(1,1,1,0.12)


        ColumnLayout {

            anchors.fill: parent
            anchors.margins: 16

            spacing: 10



            RowLayout {

                Layout.fillWidth: true


                Text {
                    text: localNotifModel.count + " notifications"

                    color: "#F5C2E7"

                    font.pixelSize: 11
                    opacity: 0.7
                    font.family: "JetBrains Mono"
                }


                Item {
                    Layout.fillWidth: true
                }


                Text {
                    id: clearAllBtn

                    text: "[ CLEAR ALL ]"

                    color: "#ff006a"

                    font.pixelSize: 10
                    font.bold: true

                    visible: localNotifModel.count > 0


                    MouseArea {
                        anchors.fill: parent

                        onClicked:
                        localNotifModel.clear()
                    }
                }
            }



            ColumnLayout {

                Layout.fillWidth: true

                spacing: 8


                Repeater {

                    model: localNotifModel


                    delegate: Rectangle {

                        Layout.fillWidth: true

                        Layout.preferredHeight:42


                        radius: 12


                        color: Qt.rgba(1,1,1,0.05)

                        border.width: 1

                        border.color:
                        Qt.rgba(1,1,1,0.08)



                        RowLayout {

                            anchors.fill: parent

                            anchors.margins: 12


                            spacing: 10



                            Text {

                                text:model.appName

                                color:"#ff006a"

                                font.pixelSize:10

                                font.bold:true
                            }



                            Rectangle {

                                width:1

                                Layout.fillHeight:true

                                color:Qt.rgba(1,1,1,0.12)
                            }



                            ColumnLayout {

                                Layout.fillWidth:true

                                spacing:2


                                Text {

                                    Layout.fillWidth:true

                                    text:model.summary

                                    color:"white"

                                    font.pixelSize:11

                                    elide:Text.ElideRight
                                }


                                Text {

                                    Layout.fillWidth:true

                                    text:model.body

                                    color:"#C3BAC6"

                                    font.pixelSize:10

                                    opacity:0.8

                                    elide:Text.ElideRight
                                }
                            }
                        }
                    }
                }


                Rectangle {

                    Layout.fillWidth:true

                    Layout.preferredHeight:50


                    visible: localNotifModel.count === 0


                    radius:12

                    color:Qt.rgba(1,1,1,0.03)


                    Text {

                        anchors.centerIn:parent

                        text:"No new notifications"

                        color:"#A6ADC8"

                        opacity:0.5

                        font.pixelSize:11
                    }
                }
            }
        }
    }



    ListModel {
        id: localNotifModel
    }


    NotificationServer {

        id: internalServer


        onNotification:(notif)=>{

            localNotifModel.insert(0,{
                "appName":String(notif.appName || "SYS").toUpperCase(),
                                   "summary":String(notif.summary || "Notification"),
                                   "body":String(notif.body || "")
            })


            while(localNotifModel.count > 2)
                localNotifModel.remove(localNotifModel.count-1)
        }
    }
}
