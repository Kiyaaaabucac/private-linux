pragma Singleton

import QtQml
import QtQuick
import Quickshell
import Quickshell.Io
import "."


Singleton {

    id:root


    // ==========================================
    // COLORS
    // ==========================================

    property string imagePath:""


    property color primary:"#888888"


    property color secondary:"#222222"


    property color accent:"#555555"





    // ==========================================
    // UPDATE COLOR FROM COVER
    // ==========================================


    function update()
    {


        if(!Players.cover || Players.cover === "")
        {
            console.log(
                "NO COVER"
            )

            return
        }



        imagePath =
        Players.cover.replace(
            "file://",
            ""
        )




        console.log(
            "COLOR EXTRACT:",
            imagePath
        )




        extractor.command = [

            "/home/alone/.config/quickshell/scripts/venv/bin/python",

            "/home/alone/.config/quickshell/scripts/color_extract.py",

            imagePath

        ]




        extractor.running=false


        extractor.running=true



    }








    // ==========================================
    // PLAYER LISTENER
    // ==========================================


    Connections {


        target:Players


        ignoreUnknownSignals:true



        function onCoverChanged()
        {


            console.log(
                "NEW COVER DETECTED:",
                Players.cover
            )



            // đợi Tauon ghi file xong

            delayTimer.restart()



        }


    }








    Timer {


        id:delayTimer


        interval:500


        repeat:false



        onTriggered:


        {

            root.update()

        }


    }










    // ==========================================
    // PYTHON PROCESS
    // ==========================================


    Process {


        id:extractor



        stdout:SplitParser {



            onRead:line=>{


                console.log(
                    "COLOR RAW:",
                    line
                )



                try {


                    let data =
                    JSON.parse(line)



                    if(data.primary)
                    {


                        root.primary =
                        data.primary



                        root.secondary =
                        data.secondary
                        ??
                        data.primary




                        root.accent =
                        data.accent
                        ??
                        data.primary




                        console.log(
                            "COLOR UPDATED:",
                            root.primary,
                            root.secondary,
                            root.accent
                        )



                    }


                }


                catch(e)
                {


                    console.log(
                        "JSON ERROR:",
                        e
                    )


                }



            }


        }






        stderr:SplitParser {



            onRead:line=>{


                console.log(
                    "COLOR ERROR:",
                    line
                )


            }


        }



    }










    // ==========================================
    // DEBUG
    // ==========================================


    Connections {


        target:root



        function onPrimaryChanged()
        {

            console.log(
                "PRIMARY CHANGED:",
                root.primary
            )

        }





        function onSecondaryChanged()
        {

            console.log(
                "SECONDARY CHANGED:",
                root.secondary
            )

        }




        function onAccentChanged()
        {

            console.log(
                "ACCENT CHANGED:",
                root.accent
            )

        }


    }









    Component.onCompleted:
    {


        console.log(
            "AlbumColors READY"
        )



        Qt.callLater(
            update
        )


    }



}
