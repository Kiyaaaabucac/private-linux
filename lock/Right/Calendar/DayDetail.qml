import QtQuick
import QtQuick.Layouts


Item {

    id: detailRoot


    implicitWidth:340
    implicitHeight:220


    property date selectedDate: new Date()

    property var events: []

    property var holidays: []



    visible: calendarRoot.detailOpen

    scale: visible ? 1 : 0.9


    Behavior on scale {

        NumberAnimation {
            duration:250
        }

    }





    Rectangle {


        anchors.fill:parent


        radius:22


        color:
        Qt.rgba(
            0,
            0,
            0,
            0.35
        )


        border.width:1


        border.color:
        Qt.rgba(
            1,
            1,
            1,
            0.15
        )





        ColumnLayout {

            anchors.fill:parent

            anchors.margins:18


            width:
            parent.width - 36


            spacing:10





            // HEADER

            Text {


                text:

                Qt.formatDate(
                    detailRoot.selectedDate,
                    "dddd, dd MMMM yyyy"
                )


                color:"white"


                font.pixelSize:16


                font.bold:true


            }






            Rectangle {

                Layout.fillWidth:true

                height:1

                color:
                Qt.rgba(
                    1,
                    1,
                    1,
                    0.1
                )

            }







            // HOLIDAY

            Repeater {

                model: detailRoot.holidays

                delegate: Item {

                    width: detailRoot.width - 36

                    height: holidayText.implicitHeight


                    Text {

                        id: holidayText


                        anchors.left: parent.left

                        anchors.right: parent.right


                        text:
                        "🇻🇳  " + modelData.name


                        color:"#F5C2E7"


                        font.pixelSize:12


                        elide: Text.ElideRight


                        maximumLineCount:2
                        wrapMode: Text.WordWrap


                        clip:true

                    }

                }

            }








            // EVENTS

            Text {


                visible:
                detailRoot.events.length > 0



                text:"Events"


                color:"#ff006a"


                font.pixelSize:12


                font.bold:true


            }





            Repeater {


                model:
                detailRoot.events



                delegate:Column {

                    width: detailRoot.width - 36

                    spacing:2



                    Text {

                        width: parent.width


                        text:
                        "● "
                        +
                        modelData.time
                        +
                        "  "
                        +
                        modelData.title


                        color:"white"


                        font.pixelSize:13


                        elide: Text.ElideRight


                        maximumLineCount:1


                        clip:true

                    }





                    Text {

                        Layout.fillWidth:true


                        text:
                        modelData.description


                        color:"#A6ADC8"


                        font.pixelSize:11


                        opacity:0.7


                        elide: Text.ElideRight


                        maximumLineCount:2
                        wrapMode: Text.WordWrap


                        clip:true

                    }

                }


            }








            Text {


                visible:

                detailRoot.events.length === 0
                &&
                detailRoot.holidays.length === 0



                text:

                "No events"



                color:"#A6ADC8"


                font.pixelSize:12


            }


        }

    }


}
