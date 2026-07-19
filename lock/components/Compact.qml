import QtQuick
import QtQuick.Layouts

import "../../../services"


Item {

    id: root


    implicitWidth:300
    implicitHeight:45



    Rectangle {

        anchors.fill:parent

        radius:22


        color:"#33000000"


        border.width:1

        border.color:"#33ffffff"



        RowLayout {


            anchors.fill:parent

            anchors.margins:12


            spacing:12



            Text {

                text:"󰁹"

                color:"white"

                font.pixelSize:16

            }



            Text {

                text:

                System.battery

                ?

                Math.round(
                    System.battery.percentage
                )
                + "%"

                :

                "N/A"


                color:"white"

                font.pixelSize:12

                font.bold:true

            }





            Item {

                Layout.fillWidth:true

            }





            Text {

                text:

                "CPU "

                +

                Math.round(
                    System.cpuUsage
                )

                +

                "%"


                color:"#ff006a"

                font.pixelSize:12

                font.bold:true

            }


        }


    }


}
