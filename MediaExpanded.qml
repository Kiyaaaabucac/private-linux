import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import Quickshell.Services.Mpris
import Quickshell.Io

import "../../../../services"


Item {

    id: root

    anchors.fill: parent


    property int gifX:1000
    property int gifY:200

    property var bars:[]

    property MprisPlayer player:
    Players.active


    property real progress:0


    property var smoothHeights:[]

    property var tracker: MediaTracker

    property real discAngle:0


    property string displayLyrics:""
    property bool lyricsSettingsOpen:false

    Component.onCompleted:{


        let arr=[]


        for(let i=0;i<48;i++)
            arr.push(2)


            root.smoothHeights=arr


            console.log(
                "MEDIA LOADED"
            )

            console.log(
                "CURRENT LYRICS:",
                Lyrics.currentLyrics
            )

            console.log(
                "MEDIA EXPANDED START"
            )


            console.log(
                "TRACKER:",
                MediaTracker
            )

    }






    //
    // ===============================
    // LYRICS CONNECTION
    // ===============================
    //

    signal openLyricsSettings()


    function toggleLyricsSettings()
    {
        console.log("REQUEST OPEN LYRICS SETTINGS")

        openLyricsSettings()
    }

    Connections {

        target: root.player

        ignoreUnknownSignals:true

        function onLoopStatusChanged(){

            loopIcon.textChanged()
        }

        function onTrackTitleChanged(){

            Lyrics.currentLine

        }


    }





    Timer {
        interval:1000
        running:true
        repeat:true

        onTriggered:{
            console.log(
                "CURRENT LINE:",
                Lyrics.currentLine
            )
        }
    }

    Timer {

        interval:500

        running:true

        repeat:true


        onTriggered:{

            root.active =
            root.active

        }

    }


    //
    // ===============================
    // CAVA
    // ===============================
    //



    Process {


        id:cavaProcess



        command:[

            "bash",
            "-c",

            "/home/alone/.config/quickshell/default/modules/dashboard/modules/media/cava-radial"

        ]



        running:true



        stdout:SplitParser{


            onRead:line=>{


                let values =
                line.split(";")
                .filter(v=>v!=="")
                .map(Number)



                root.bars=values



                let smooth=[]



                for(let i=0;i<values.length;i++){


                    let old =
                    root.smoothHeights[i] || 0



                    smooth.push(

                        old +
                        (
                            values[i]-old
                        )
                        *
                        0.35

                    )

                }



                root.smoothHeights=smooth


            }

        }

    }









    //
    // ===============================
    // MUSIC PROGRESS TIMER
    // ===============================
    //



    Timer {


        interval:50


        running:true


        repeat:true



        onTriggered:{


            if(!root.player)
                return




                if(root.player.length>0){


                    root.progress =

                    Math.max(

                        0,

                        Math.min(

                            1,

                            root.player.position /
                            root.player.length

                        )

                    )

                }

                else{

                    root.progress=0

                }


        }

    }


    //
    // ===============================
    // DISC ROTATE
    // ===============================
    //



    Timer {


        interval:16


        running:
        Players.isPlaying


        repeat:true



        onTriggered:{


            root.discAngle =
            (
                root.discAngle+0.6
            )
            %
            360


        }

    }








    function formatTime(sec){


        if(!sec || isNaN(sec))
            return "0:00"



            let m =
            Math.floor(sec/60)



            let s =
            Math.floor(sec%60)



            return m+":"+
            (
                s<10
                ?
                "0"+s
                :
                s
            )

    }

    function getPlayerName(){


        if(!root.player)
            return "No Player"



            let id =
            String(
                root.player.identity
            )



            if(id.length>15)
                id=id.substring(0,15)



                return id

    }

    // =====================================================
    // Lyrics
    // =====================================================

    Item {



        id:lyricsWidget

        width:500
        height:160


        x:195
        y:83



        Rectangle {

            id:lyrics

            anchors.fill:parent

            radius:16

            color:"#3d1b32"

            opacity:0

        }





        Item {

            id:lyricsBox

            anchors.fill:parent

            clip:true




            Column {

                id:lyricColumn


                width:parent.width


                spacing:8


                y:0



                Behavior on y {

                    NumberAnimation {

                        duration:450

                        easing.type:Easing.OutCubic

                    }

                }






                // =========================
                // PREVIOUS
                // =========================


                Text {


                    id:previousLyric


                    width:parent.width



                    text:

                    Lyrics.displayedIndex > 0

                    ?

                    Lyrics.lyricLines[
                        Lyrics.displayedIndex-1
                    ].text

                    :

                    ""



                    horizontalAlignment:
                    Text.AlignHCenter



                    wrapMode:
                    Text.Wrap



                    color:"#F5C2E7"


                    opacity:0.35



                    font.pixelSize:11



                }








                Rectangle {

                    width:220

                    height:1


                    anchors.horizontalCenter:
                    parent.horizontalCenter



                    color:"#ff006a"


                    opacity:0.5

                }







                // =========================
                // CURRENT KARAOKE
                // =========================

                Item {

                    id: currentLyric

                    width: parent.width
                    height:45


                    property string currentText:
                    Lyrics.currentLine



                    Text {

                        id:baseText

                        height:30

                        width:Math.min(
                            implicitWidth,
                            490
                        )

                        maximumLineCount:1

                        elide:Text.ElideRight


                        anchors.horizontalCenter:
                        parent.horizontalCenter


                        anchors.verticalCenter:
                        parent.verticalCenter



                        text:
                        currentLyric.currentText



                        color:"#555"



                        horizontalAlignment:
                        Text.AlignHCenter


                        verticalAlignment:
                        Text.AlignVCenter



                        font.pixelSize:11

                        font.bold:true


                    }



                    Item {

                        id:karoMask


                        anchors.left:
                        baseText.left


                        anchors.top:
                        baseText.top



                        width:

                        baseText.width *
                        Lyrics.lineProgress



                        height:
                        baseText.height



                        clip:true



                        Text {

                            id:karoText


                            width:
                            baseText.width


                            height:
                            baseText.height



                            text:
                            currentLyric.currentText



                            color:"#ff006a"



                            horizontalAlignment:
                            Text.AlignHCenter


                            verticalAlignment:
                            Text.AlignVCenter



                            font.pixelSize:11

                            font.bold:true

                            layer.enabled:true


                            layer.effect:

                            DropShadow {


                                radius:8


                                samples:16


                                color:"#ff006a"


                            }


                        }


                    }








                    scale:1



                    Behavior on scale {


                        NumberAnimation {


                            duration:250


                            easing.type:

                            Easing.OutBack


                        }

                    }



                    opacity:1


                    Behavior on opacity {


                        NumberAnimation {


                            duration:250


                        }

                    }


                }









                Rectangle {

                    width:220

                    height:1


                    anchors.horizontalCenter:
                    parent.horizontalCenter


                    color:"#ff006a"


                    opacity:0.5

                }








                // =========================
                // NEXT
                // =========================


                Text {


                    id:nextLyric



                    width:parent.width




                    text:


                    Lyrics.displayedIndex + 1
                    <
                    Lyrics.lyricLines.length

                    ?

                    Lyrics.lyricLines[
                        Lyrics.displayedIndex+1
                    ].text

                    :

                    ""



                    horizontalAlignment:

                    Text.AlignHCenter



                    wrapMode:

                    Text.Wrap



                    color:"#F5C2E7"


                    opacity:0.35



                    font.pixelSize:11


                }



            }









            // =========================
            // SLIDE ANIMATION
            // =========================

            SequentialAnimation {

                id:lyricFade


                ParallelAnimation {


                    NumberAnimation {

                        target:currentLyric

                        property:"opacity"

                        from:0.5

                        to:1

                        duration:150

                    }



                    NumberAnimation {

                        target:currentLyric

                        property:"scale"

                        from:1.08

                        to:1

                        duration:250

                        easing.type:Easing.OutBack

                    }

                }

            }

            NumberAnimation {
                target: lyricColumn
                property: "y"
                from: 18
                to: 0
                duration: 180
            }

        }



        Connections {


            target:Lyrics





            function onCurrentIndexChanged(){

                Lyrics.displayedIndex =
                Lyrics.currentIndex


                currentLyric.scale=1.08

                lyricFade.restart()

            }




            function onCurrentLineChanged(){



                console.log(
                    "UI LYRIC:",
                    Lyrics.currentLine
                )

            }


        }


        Timer {

            id:fadeTimer

            interval:50


            onTriggered:{

                currentLyric.opacity=1

            }

        }
    }

    // =====================================================
    // CONTROL BUTTONS
    // =====================================================


    Item {

        id: controlWidget


        width:240
        height:50


        // chỉ chỉnh 2 dòng này
        x:315
        y:170



        RowLayout {

            anchors.centerIn: parent


            spacing:12



            // SHUFFLE
            Item {

                width:36
                height:36


                Text {

                    anchors.centerIn:parent

                    text:"⇄"

                    font.pixelSize:18

                    color:"white"

                }


                MouseArea {

                    anchors.fill:parent

                    onClicked:
                    Players.toggleShuffle()

                }

            }



            // PREVIOUS
            Item {

                width:36
                height:36


                Text {

                    anchors.centerIn:parent

                    text:"⏮"

                    color:"white"

                }


                MouseArea {

                    anchors.fill:parent

                    onClicked:

                    if(root.player)
                        root.player.previous()

                }

            }



            // PLAY
            Item {

                width:40
                height:40


                Text {

                    anchors.centerIn:parent


                    text:
                    Players.isPlaying
                    ?
                    "⏸"
                    :
                    "▶"


                    font.pixelSize:20

                    color:"white"

                }


                MouseArea {

                    anchors.fill:parent


                    onClicked:

                    if(root.player)
                        root.player.togglePlaying()

                }

            }



            // NEXT
            Item {

                width:36
                height:36


                Text {

                    anchors.centerIn:parent

                    text:"⏭"

                    color:"white"

                }


                MouseArea {

                    anchors.fill:parent


                    onClicked:

                    if(root.player)
                        root.player.next()

                }

            }



            // LOOP
            Item {

                width:36
                height:36


                Text {

                    id:loopBtn

                    anchors.centerIn:parent


                    text:"↻"


                    font.pixelSize:18

                    font.bold:true



                    readonly property int mode: {

                        if(!root.player)
                            return 0


                            let id =
                            String(root.player.identity || "")
                            .toLowerCase()



                            if(id.includes("tauon"))
                                return Players.tauonLoopState


                                return root.player.loopStatus

                    }



                    color:

                    mode > 0

                    ?

                    "#ff006a"

                    :

                    "white"



                    opacity:

                    mode > 0

                    ?

                    1

                    :

                    0.45




                    Text {


                        anchors.left:
                        parent.right


                        anchors.leftMargin:-3


                        anchors.bottom:
                        parent.bottom


                        anchors.bottomMargin:-3



                        text:

                        loopBtn.mode === 1

                        ?

                        "1"

                        :

                        loopBtn.mode === 2

                        ?

                        "•"

                        :

                        ""



                        font.pixelSize:

                        loopBtn.mode === 1

                        ?

                        9

                        :

                        14



                        font.bold:true


                        color:"#ff006a"


                    }


                }



                MouseArea {

                    anchors.fill:parent


                    onClicked:

                    Players.forceToggleLoop()

                }

            }

            Item {


                width:36
                height:36

                Item {

                    width:36
                    height:36


                    Text {

                        anchors.centerIn:parent

                        text:"⚙"

                        color:"white"

                        font.pixelSize:18

                    }


                    MouseArea {

                        anchors.fill:parent


                        onClicked:{


                            console.log("OPEN LYRICS SETTINGS")


                            toggleLyricsSettings()


                        }

                    }

                }

            }
        }
    }

    // ========================================================
    // ALBUM + CAVA
    // ========================================================


    Item {


        id:radialAndummidk



        width:250

        height:40




        // CHỈ SỬA 2 DÒNG NÀY

        x:-15

        y:95






        Item {


            id:radialCavaContainer


            anchors.centerIn:parent


            width:110

            height:110





            Repeater {


                model:
                root.bars.length



                Item {


                    anchors.fill:parent



                    rotation:
                    index*(360/48)



                    Rectangle {


                        anchors.bottom:
                        parent.top


                        anchors.horizontalCenter:
                        parent.horizontalCenter


                        anchors.bottomMargin:2



                        width:2



                        height:

                        Math.min(

                            50,

                            Math.max(

                                4,

                                root.smoothHeights[index]*1

                            )

                        )



                        radius:2



                        color:

                        index%2===0

                        ?

                        "#ff006a"

                        :

                        "#F5C2E7"

                    }

                }

            }

        }





        Rectangle {


            id:albumBorderCircle



            anchors.centerIn:parent



            width:110

            height:110



            radius:55



            color:"#1a1625"



            border.width:2

            border.color:"#ff006a"



            z:2





            Item {


                anchors.fill:parent


                rotation:
                root.discAngle





                Image {


                    id:albumArtSource



                    anchors.fill:parent



                    anchors.margins:3



                    source:

                    root.player

                    ?

                    Players.getArtUrl(root.player)

                    :

                    ""



                    fillMode:
                    Image.PreserveAspectCrop



                    visible:false

                }





                Rectangle {


                    id:maskCircle



                    anchors.fill:parent



                    anchors.margins:3



                    radius:
                    width/2



                    visible:false

                }





                OpacityMask {


                    anchors.fill:parent



                    anchors.margins:3



                    source:
                    albumArtSource



                    maskSource:
                    maskCircle



                    visible:
                    albumArtSource.status
                    === Image.Ready

                }





                Text {


                    anchors.centerIn:parent



                    text:"🎵"



                    font.pixelSize:32



                    color:"#F5C2E7"



                    visible:
                    albumArtSource.status
                    !==Image.Ready

                }

            }

        }

    }



    //
    // ===============================
    // FLOATING PROGRESS BAR
    // ĐỂ NGOÀI ROWLAYOUT
    // ===============================
    //


    Item {


        id:progressWidget



        width:300

        height:40




        // CHỈ SỬA 2 DÒNG NÀY

        x:288

        y:210






        Rectangle {


            id:progressTrack



            width:
            parent.width


            height:4



            radius:2



            color:"#1d192b"




            Rectangle{


                id:progressFill



                height:
                parent.height



                width:
                parent.width *
                root.progress



                radius:2



                color:"#ff006a"

            }

        }






        MouseArea {


            anchors.fill:
            progressTrack



            function seek(x){


                if(root.player &&
                    root.player.length>0){


                    let value =

                    Math.max(

                        0,

                        Math.min(

                            1,

                            x /
                            progressTrack.width

                        )

                    )



                    root.player.position =
                    root.player.length *
                    value


                    }

            }



            onPressed:
            seek(mouse.x)



            onPositionChanged:{


                if(pressed)
                    seek(mouse.x)

            }

        }






        Text {


            anchors.top:
            progressTrack.bottom



            anchors.topMargin:6



            anchors.left:
            parent.left



            text:

            root.player

            ?

            root.formatTime(
                root.player.position
            )

            :

            "0:00"



            color:"#ff006a"



            font.pixelSize:10

        }





        Text {


            anchors.top:
            progressTrack.bottom



            anchors.topMargin:6



            anchors.right:
            parent.right



            text:

            root.player

            ?

            root.formatTime(
                root.player.length
            )

            :

            "0:00"



            color:"white"



            opacity:0.5



            font.pixelSize:10

        }

    }

    // =====================================================
    // LYRICS SETTINGS PANEL
    // =====================================================



    // ========================================================
    // MAIN LAYOUT
    // ========================================================


    RowLayout {


        anchors.fill: parent

        anchors.margins:22

        spacing:16















        // ========================================================
        // INFO BLOCK
        // ========================================================


        ColumnLayout {


            id:middleInfoBlock



            Layout.fillWidth:true



            Layout.preferredHeight:300

            Layout.topMargin:1

            Layout.rightMargin:-155



            spacing:4






            ColumnLayout {


                Layout.fillWidth:true



                spacing:2






                Text {


                    text:

                    root.player

                    ?

                    root.player.trackTitle ||
                    "Unknown Track"

                    :

                    "No Music Playing"




                    font.pixelSize:14



                    font.bold:true



                    color:"white"



                    horizontalAlignment:
                    Text.AlignHCenter



                    Layout.fillWidth:true



                    elide:
                    Text.ElideRight

                }







                Text {


                    text:

                    root.player

                    ?

                    root.player.trackArtist ||
                    "Unknown Artist"

                    :

                    ""



                    font.pixelSize:11



                    color:"#F5C2E7"


                    anchors.horizontalCenter:
                    parent.horizontalCenter


                    anchors.verticalCenter:
                    parent.verticalCenter

                    horizontalAlignment:
                    Text.AlignHCenter


                    verticalAlignment:
                    Text.AlignVCenter

                    Layout.topMargin:20

                    Layout.preferredWidth:300



                    elide:
                    Text.ElideRight

                }

            }



            // =====================================================
            // PLAYER SELECTOR
            // =====================================================


            Item {


                width:100

                height:50





                Rectangle {


                    width:110

                    height:22



                    x:360

                    y:-130



                    radius:6



                    color:"#3d1b32"



                    border.width:1

                    border.color:"#ff006a"





                    Text {


                        anchors.centerIn:parent



                        text:
                        root.getPlayerName()



                        color:"white"



                        font.pixelSize:9

                    }

                }

            }


        }

    }
}
