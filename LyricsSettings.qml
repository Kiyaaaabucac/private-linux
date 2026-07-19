import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt5Compat.GraphicalEffects

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

import "../../../../services"



Item {

    id:root


    width:200
    height:260


    implicitWidth:200
    implicitHeight:260


    clip:true



    // ==================================================
    // ALBUM COLOR ENGINE
    // ==================================================

    property color albumPrimary:
    AlbumColors.primary


    property color albumSecondary:
    AlbumColors.secondary



    property color accent:
    albumPrimary



    property color accentSoft:

    Qt.rgba(
        albumPrimary.r,
        albumPrimary.g,
        albumPrimary.b,
        0.35
    )



    property color accentLight:

    Qt.lighter(
        albumPrimary,
        1.5
    )



    property color textPrimary:

    Qt.lighter(
        albumPrimary,
        3.0
    )



    property color textSecondary:

    Qt.lighter(
        albumSecondary,
        2.2
    )



    property color panelTop:

    Qt.rgba(
        albumPrimary.r,
        albumPrimary.g,
        albumPrimary.b,
        0.35
    )



    property color panelBottom:

    Qt.rgba(
        albumSecondary.r,
        albumSecondary.g,
        albumSecondary.b,
        0.88
    )



    property color card:

    Qt.rgba(
        albumPrimary.r,
        albumPrimary.g,
        albumPrimary.b,
        0.16
    )



    property color cardStrong:

    Qt.rgba(
        albumPrimary.r,
        albumPrimary.g,
        albumPrimary.b,
        0.30
    )



    property color border:

    Qt.rgba(
        albumPrimary.r,
        albumPrimary.g,
        albumPrimary.b,
        0.35
    )



    property color glow:

    Qt.rgba(
        albumPrimary.r,
        albumPrimary.g,
        albumPrimary.b,
        0.45
    )




    Behavior on albumPrimary {

        ColorAnimation {

            duration:500

        }

    }


    Behavior on albumSecondary {

        ColorAnimation {

            duration:500

        }

    }







    // ==================================================
    // MPRIS
    // ==================================================


    property var player:

    Players.active





    function trackTitle()
    {
        return Players.title ?? "Unknown"
    }




    function trackArtist()
    {
        return Players.artist ?? "Unknown"
    }




    function escapeRegex(text)
    {

        return text.replace(
            /[.*+?^${}()|[\]\\]/g,
                            '\\$&'
        )

    }








    // ==================================================
    // STATE
    // ==================================================


    property bool opened:false


    property bool visiblePanel:false



    property string searchText:""



    property string statusText:"NONE"


    property string statusIcon:"○"




    property int hiddenX:120


    property int shownX:0





    property real minimumWidth:200

    property real minimumHeight:260


    property real maximumWidth:420

    property real maximumHeight:700







    x:hiddenX


    visible:visiblePanel







    // ==================================================
    // ANIMATION
    // ==================================================


    scale:

    visiblePanel

    ?

    1

    :

    0.95




    opacity:

    visiblePanel

    ?

    1

    :

    0






    Behavior on x {


        NumberAnimation {

            duration:280

            easing.type:Easing.OutCubic

        }

    }





    Behavior on scale {


        NumberAnimation {

            duration:250

            easing.type:Easing.OutCubic

        }

    }






    Behavior on opacity {


        NumberAnimation {

            duration:220

            easing.type:Easing.OutCubic

        }

    }








    // ==================================================
    // OPEN / CLOSE
    // ==================================================



    function open()
    {

        visiblePanel=true


        x=hiddenX


        Qt.callLater(()=>{

            x=shownX

        })


        opened=true


        customFiles.reload()

    }







    function close()
    {

        opened=false


        x=hiddenX


        closeTimer.restart()

    }






    Timer {


        id:closeTimer


        interval:250


        onTriggered:{


            if(!opened)

                visiblePanel=false


        }


    }








    // ==================================================
    // COLOR LIVE UPDATE
    // ==================================================


    Connections {


        target:AlbumColors


        function onPrimaryChanged()
        {

            console.log(
                "PRIMARY UPDATE:",
                AlbumColors.primary
            )

        }



        function onSecondaryChanged()
        {

            root.albumSecondary =
            AlbumColors.secondary


            console.log(
                "SECONDARY UPDATE:",
                AlbumColors.secondary
            )

        }


    }








    // ==================================================
    // PLAYER UPDATE
    // ==================================================


    Connections {


        target:Players


        ignoreUnknownSignals:true



        function onActiveChanged()
        {

            root.player =
            Players.active

        }


        function onCoverChanged()
        {

            console.log(
                "NEW COVER:",
                Players.cover
            )

        }


    }









    // ==================================================
    // GLASS BACKGROUND
    // ==================================================


    Rectangle {


        anchors.fill:parent


        radius:24



        clip:true




        gradient:


        Gradient {


            GradientStop {


                position:0.0


                color:root.panelTop


            }


            GradientStop {


                position:1.0


                color:root.panelBottom


            }


        }




        border.width:1


        border.color:root.border






        layer.enabled:true


        layer.effect:


        FastBlur {


            radius:18

        }



    }






    // overlay kính


    Rectangle {


        anchors.fill:parent


        radius:24


        color:

        Qt.rgba(
            1,
            1,
            1,
            0.04
        )


    }





    // ==================================================
    // MAIN UI
    // ==================================================


    ColumnLayout {


        anchors.fill:parent


        anchors.margins:12


        spacing:8







        // ==================================================
        // HEADER
        // ==================================================


        RowLayout {


            Layout.fillWidth:true



            Text {


                text:"🎵 Lyrics"



                color:root.textPrimary



                font.pixelSize:14


                font.bold:true



                Layout.fillWidth:true


            }







            Rectangle {


                width:24


                height:24


                radius:12



                color:root.cardStrong





                Text {


                    anchors.centerIn:parent



                    text:"×"



                    color:root.textPrimary



                    font.pixelSize:15


                    font.bold:true


                }







                MouseArea {


                    anchors.fill:parent



                    onClicked:


                    root.close()



                }


            }



        }








        // ==================================================
        // CURRENT TRACK CARD
        // ==================================================


        Rectangle {


            Layout.fillWidth:true


            height:78


            radius:16



            color:root.card



            border.width:1


            border.color:root.border






            RowLayout {


                anchors.fill:parent


                anchors.margins:8



                spacing:10







                Rectangle {


                    width:60


                    height:60


                    radius:14



                    clip:true



                    color:root.cardStrong






                    Image {


                        id:albumArt



                        anchors.fill:parent




                        source:

                        root.player

                        ?

                        root.player.trackArtUrl

                        +

                        "?v="

                        +

                        Players.mediaVersion

                        :

                        ""





                        fillMode:

                        Image.PreserveAspectCrop



                        asynchronous:true


                        cache:false



                    }





                    Rectangle {


                        anchors.fill:parent


                        radius:14



                        color:"transparent"



                        border.width:1


                        border.color:root.border


                    }




                }







                ColumnLayout {


                    Layout.fillWidth:true



                    spacing:4





                    Text {


                        Layout.fillWidth:true



                        text:

                        root.trackTitle()



                        color:root.textPrimary



                        font.pixelSize:11


                        font.bold:true



                        elide:

                        Text.ElideRight



                    }





                    Text {


                        Layout.fillWidth:true



                        text:

                        root.trackArtist()



                        color:root.textSecondary



                        font.pixelSize:9



                        elide:

                        Text.ElideRight



                    }




                }



            }



        }









        // ==================================================
        // SOURCE STATUS
        // ==================================================


        RowLayout {


            Layout.fillWidth:true





            Text {


                text:"Source"


                color:root.textSecondary



                font.pixelSize:10



                Layout.fillWidth:true



            }







            Rectangle {


                width:75


                height:20


                radius:10



                color:root.cardStrong






                Text {


                    anchors.centerIn:parent




                    text:

                    Lyrics.lyricsSource === ""

                    ?

                    "NONE"

                    :

                    Lyrics.lyricsSource.toUpperCase()





                    color:root.textPrimary



                    font.pixelSize:9



                }


            }



        }









        // ==================================================
        // STATUS CARD
        // ==================================================


        Rectangle {


            Layout.fillWidth:true


            height:28



            radius:12



            color:root.card



            border.width:1


            border.color:root.border






            RowLayout {


                anchors.fill:parent



                anchors.margins:8



                spacing:8






                Text {


                    text:root.statusIcon



                    color:root.accentLight



                    font.pixelSize:12



                }






                Text {


                    text:root.statusText



                    color:root.textPrimary



                    font.pixelSize:10



                }




            }



        }








        // ==================================================
        // SOURCE SELECT
        // ==================================================


        ComboBox {


            id:sourceSelector



            Layout.fillWidth:true





            model:


            [

                "Auto",

                "Cache",

                "Custom",

                "LRCLIB"

            ]







            currentIndex:


            Lyrics.sourceMode || 0






            onCurrentIndexChanged:{


                Lyrics.sourceMode=currentIndex


            }








            background:


            Rectangle {


                radius:12


                color:root.card



                border.width:1



                border.color:root.border



            }








            contentItem:


            Text {


                text:

                sourceSelector.displayText




                color:root.textPrimary



                font.pixelSize:11



                leftPadding:12



                verticalAlignment:

                Text.AlignVCenter



            }



        }









        // ==================================================
        // SEARCH
        // ==================================================


        TextField {


            id:searchBox



            Layout.fillWidth:true



            height:30





            placeholderText:

            "Search LRC..."







            color:root.textPrimary



            font.pixelSize:10








            background:


            Rectangle {


                radius:12


                color:root.card



                border.width:1



                border.color:root.border



            }







            onTextChanged:{


                root.searchText=text


                customFiles.updateFilter()


            }



        }









        // ==================================================
        // CUSTOM TITLE
        // ==================================================


        Text {


            text:"Custom Lyrics"



            color:root.textPrimary



            font.pixelSize:12



            font.bold:true



        }









        // ==================================================
        // FILE LIST
        // ==================================================


        Flickable {


            Layout.fillWidth:true



            Layout.fillHeight:true



            clip:true



            contentHeight:fileColumn.height






            ScrollBar.vertical:


            ScrollBar {


                policy:

                ScrollBar.AsNeeded


            }






            Column {


                id:fileColumn



                width:parent.width



                spacing:6







                Repeater {


                    model:

                    customFiles.filteredFiles







                    delegate:


                    Rectangle {



                        width:fileColumn.width



                        height:34



                        radius:12






                        color:


                        Lyrics.selectedCustomFile ===

                        Lyrics.customPath + modelData


                        ?

                        root.accentSoft

                        :

                        root.card





                        border.width:1



                        border.color:

                        root.border








                        Text {


                            anchors.centerIn:parent



                            width:parent.width-20



                            text:modelData



                            color:root.textPrimary



                            font.pixelSize:9



                            horizontalAlignment:

                            Text.AlignHCenter



                            elide:

                            Text.ElideRight



                        }








                        MouseArea {


                            anchors.fill:parent



                            onClicked:{



                                Lyrics.setCustomFile(

                                    Lyrics.customPath +

                                    modelData

                                )



                                root.statusText="CUSTOM"


                                root.statusIcon="●"



                            }


                        }


                    }


                }


            }



        }

        // ==================================================
        // LYRIC PREVIEW
        // ==================================================


        Rectangle {


            Layout.fillWidth:true



            height:55



            radius:14



            color:root.card



            border.width:1



            border.color:root.border






            Text {


                anchors.fill:parent



                anchors.margins:10





                text:


                Lyrics.currentLine === ""

                ?

                "No lyric preview"

                :

                Lyrics.currentLine






                color:root.textSecondary



                font.pixelSize:10



                wrapMode:

                Text.Wrap



                elide:

                Text.ElideRight



            }



        }








        // ==================================================
        // ACTION BUTTONS
        // ==================================================


        RowLayout {


            Layout.fillWidth:true



            spacing:6







            Rectangle {


                Layout.fillWidth:true



                height:30



                radius:12



                color:root.card



                border.width:1


                border.color:root.border






                Text {


                    anchors.centerIn:parent



                    text:"📂 Folder"



                    color:root.textPrimary



                    font.pixelSize:10



                }







                MouseArea {


                    anchors.fill:parent



                    onClicked:{


                        folderProcess.running=false


                        folderProcess.running=true



                    }


                }



            }









            Rectangle {


                Layout.fillWidth:true



                height:30



                radius:12



                color:root.card



                border.width:1



                border.color:root.border






                Text {


                    anchors.centerIn:parent



                    text:"✕ Clear"



                    color:root.textPrimary



                    font.pixelSize:10



                }







                MouseArea {


                    anchors.fill:parent



                    onClicked:{



                        Lyrics.selectedCustomFile=""



                        root.statusText="NONE"


                        root.statusIcon="○"





                        Lyrics.setTrack(

                            Lyrics.currentTitle,

                            Lyrics.currentArtist,

                            Lyrics.currentAlbum

                        )


                    }



                }



            }



        }









        // ==================================================
        // RELOAD BUTTON
        // ==================================================


        Rectangle {


            Layout.fillWidth:true



            height:32



            radius:14



            color:root.accentSoft



            border.width:1



            border.color:root.accentLight






            Text {


                anchors.centerIn:parent



                text:"↻ Reload Lyrics"



                color:root.textPrimary



                font.pixelSize:11



                font.bold:true



            }







            MouseArea {


                anchors.fill:parent



                onClicked:{



                    root.statusText="LOADING"


                    root.statusIcon="◌"





                    Lyrics.setTrack(

                        Lyrics.currentTitle,

                        Lyrics.currentArtist,

                        Lyrics.currentAlbum

                    )






                    Qt.callLater(()=>{


                        root.statusText =


                        Lyrics.lyricsSource === ""

                        ?

                        "NONE"

                        :

                        Lyrics.lyricsSource.toUpperCase()



                        root.statusIcon="●"



                    })



                }



            }



        }




    }









    // ==================================================
    // RESIZE HANDLE
    // ==================================================


    Rectangle {


        width:18


        height:18



        anchors.right:parent.right


        anchors.bottom:parent.bottom



        color:"transparent"






        Text {


            anchors.centerIn:parent



            text:"◢"



            color:root.accentLight



            font.pixelSize:14



        }







        MouseArea {


            anchors.fill:parent



            cursorShape:

            Qt.SizeFDiagCursor






            property real startX

            property real startY


            property real startWidth


            property real startHeight







            onPressed:{



                startX=mouse.x


                startY=mouse.y



                startWidth=root.width


                startHeight=root.height



            }








            onPositionChanged:{



                if(mouse.buttons & Qt.LeftButton)

                {



                    root.width = Math.min(

                        root.maximumWidth,

                        Math.max(

                            root.minimumWidth,

                            startWidth +

                            mouse.x -

                            startX

                        )

                    )







                    root.height = Math.min(

                        root.maximumHeight,

                        Math.max(

                            root.minimumHeight,

                            startHeight +

                            mouse.y -

                            startY

                        )

                    )



                }



            }



        }



    }









    // ==================================================
    // OPEN FOLDER PROCESS
    // ==================================================


    Process {


        id:folderProcess



        command:


        [

            "xdg-open",

            Lyrics.customPath

        ]



    }









    // ==================================================
    // CUSTOM FILE MANAGER
    // ==================================================


    QtObject {


        id:customFiles



        property var files:[]



        property var filteredFiles:[]







        function reload()

        {



            reader.running=false



            reader.buffer=""






            reader.command=


            [

                "bash",

                "-c",

                "ls -1 \"" +

                Lyrics.customPath +

                "\" 2>/dev/null"

            ]







            reader.running=true



        }







        function updateFilter()

        {



            filteredFiles =



            files.filter(


                x =>


                x.toLowerCase()


                .includes(


                    root.searchText.toLowerCase()

                )


            )


        }



    }









    // ==================================================
    // FILE READER
    // ==================================================


    Process {


        id:reader



        property string buffer:""







        stdout:


        SplitParser {



            onRead:line=>{



                reader.buffer +=


                line + "\n"



            }



        }







        onExited:{



            customFiles.files =



            reader.buffer


            .split("\n")



            .filter(


                x =>


                x.endsWith(".lrc")


            )






            customFiles.updateFilter()



        }



    }









    // ==================================================
    // INIT
    // ==================================================


    Component.onCompleted:{



        console.log(

            "LyricsSettings loaded"

        )





        customFiles.reload()



    }



}
