import QtQuick
import QtQuick.Layouts

import Quickshell.Services.UPower
import "../../../services"


Item {

    id: root


    implicitWidth:220
    implicitHeight:140



    readonly property var battery:
    UPower.displayBattery




    function uptime()
    {

        if(typeof System === "undefined")
            return "Unknown"


            let sec = System.uptime


            let h = Math.floor(sec / 3600)

            let m = Math.floor(
                (sec % 3600) / 60
            )


            if(h > 0)

                return h + "h " + m + "m"


                return m + "m"

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


            anchors.margins:14


            spacing:5





            Text {


                text:"   󰕈  SYSTEM"


                color:"#ff006a"


                font.pixelSize:25


                font.bold:true


                font.family:
                "JetBrains Mono"

            }





            Text {

                Layout.fillWidth:true


                text:

                "OS      : Ubuntu Linux"


                color:"white"


                font.pixelSize:15


                font.family:
                "JetBrains Mono"


                elide:
                Text.ElideRight

            }





            Text {


                Layout.fillWidth:true


                text:

                "WM      : Hyprland"


                color:"white"


                font.pixelSize:15


                font.family:
                "JetBrains Mono"


            }






            Text {


                Layout.fillWidth:true


                text:

                "Kernel  : Linux"


                color:"white"


                font.pixelSize:15


                opacity:0.8


                font.family:
                "JetBrains Mono"

            }






            Text {


                Layout.fillWidth:true


                text:

                "CPU     : i5-1135G7"


                color:"white"


                font.pixelSize:15


                opacity:0.8


                font.family:
                "JetBrains Mono"


                elide:
                Text.ElideRight

            }






            Text {


                Layout.fillWidth:true


                text:

                "UP      : " + root.uptime()


                color:"white"


                font.pixelSize:15


                font.family:
                "JetBrains Mono"


            }






            Text {


                Layout.fillWidth:true


                text:


                battery

                ?

                "BAT     : "
                +
                Math.round(
                    battery.percentage
                )
                +
                "% "
                +
                (
                    battery.state === 1
                    ?
                    "⚡"
                    :
                    ""
                )

                :

                "BAT     : N/A"



                color:"#ff006a"


                font.pixelSize:15


                font.family:
                "JetBrains Mono"


            }



        }


    }


}
