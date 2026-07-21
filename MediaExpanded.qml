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

    // =========================================================================
    // 🧠 BỘ LỌC ĐA SẮC ĐỘNG NÂNG CAO (CHỐNG LỖI CHUYỂN MÀU ĐEN TUYỀN)
    // =========================================================================
    property color albumPrimary: AlbumColors.primary
    property color albumSecondary: AlbumColors.secondary

    property color textPrimary: Qt.lighter(albumPrimary, 3.0)  // Kích sáng hệ 3 cho chữ tiêu đề
    property color accentLight: Qt.lighter(albumPrimary, 1.5)  // Màu sắc nghệ thuật cho các nút bấm

    // 🌟 GIẢI PHÁP CHÍ MẠNG: Thêm hàm bẫy lỗi kiểm tra mã màu hợp lệ cho thuộc tính textSecondary!
    // Nếu biến albumSecondary hợp lệ và không phải màu đen thô, tiến hành kích sáng 2.2 lần.
    // Ngược lại, ép trả về màu trắng xám khói (#cbc7ca) chuẩn để chống sập màu đen tuyền!
    property color textSecondary: {
        try {
            // Kiểm tra nếu mã màu hợp lệ (không rỗng, không phải màu đen chết)
            if (albumSecondary && String(albumSecondary) !== "#000000" && String(albumSecondary) !== "transparent") {
                return Qt.lighter(albumSecondary, 2.2);
            }
        } catch(e) {}
        return "#cbc7ca"; // Màu trắng xám khói mumei dự phòng siêu đẹp, siêu sáng rõ
    }

    // Hoạt họa chuyển đổi màu sắc mềm mại trong 500ms giữa các bài hát
    Behavior on albumPrimary { ColorAnimation { duration: 500 } }
    Behavior on albumSecondary { ColorAnimation { duration: 500 } }


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

    // =====================================================================
    // Lyrics (ĐỒNG BỘ MÀU STATE ĐIỆN ẢNH - ĐÃ VÁ LỖI CẤU TRÚC NGOẶC NHỌN)
    // =====================================================================
    Item {
        id: lyricsWidget
        width: 500
        height: 160
        x: 195
        y: 83

        Rectangle {
            id: lyrics
            anchors.fill: parent
            radius: 16
            color: "#3d1b32"
            opacity: 0
        }

        Item {
            id: lyricsBox
            anchors.fill: parent
            clip: true

            Column {
                id: lyricColumn
                width: parent.width
                spacing: 8
                y: 0

                Behavior on y {
                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.OutCubic
                    }
                }

                // =========================
                // PREVIOUS
                // =========================
                Text {
                    id: previousLyric
                    width: parent.width
                    text: Lyrics.displayedIndex > 0 ? Lyrics.lyricLines[Lyrics.displayedIndex - 1].text : ""
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    color: root.textSecondary
                    opacity: 0.35
                    font.pixelSize: 11
                }

                Rectangle {
                    width: 220
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.accentLight
                    opacity: 0.3
                }

                // =========================
                // CURRENT KARAOKE
                // =========================
                Item {
                    id: currentLyric
                    width: parent.width
                    height: 45
                    property string currentText: Lyrics.currentLine

                    Text {
                        id: baseText
                        height: 30
                        width: Math.min(implicitWidth, 490)
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: currentLyric.currentText
                        color: "#555"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Item {
                        id: karoMask
                        anchors.left: baseText.left
                        anchors.top: baseText.top
                        width: baseText.width * Lyrics.lineProgress
                        height: baseText.height
                        clip: true

                        Text {
                            id: karoText
                            width: baseText.width
                            height: baseText.height
                            text: currentLyric.currentText
                            color: root.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 18
                            font.bold: true
                            layer.enabled: true
                            layer.effect: DropShadow {
                                radius: 8
                                samples: 16
                                color: root.accentLight
                            }
                        }
                    }

                    scale: 1
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                    opacity: 1
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                }

                Rectangle {
                    width: 220
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: root.accentLight
                    opacity: 0.3
                }

                // =========================
                // NEXT
                // =========================
                Text {
                    id: nextLyric
                    width: parent.width
                    text: (Lyrics.displayedIndex + 1 < Lyrics.lyricLines.length) ? Lyrics.lyricLines[Lyrics.displayedIndex + 1].text : ""
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    color: root.textSecondary
                    opacity: 0.35
                    font.pixelSize: 11
                }
            } // 🌟 ĐÃ VÁ: Đóng ngoặc nhọn của thẻ Column chuẩn xác!

            // =========================================================================
            // ĐOẠN HOẠT HỌA TRƯỢT DÒNG CHỮ (SLIDE ANIMATION MATRIX)
            // =========================================================================
            SequentialAnimation {
                id: lyricFade
                ParallelAnimation {
                    NumberAnimation {
                        target: currentLyric
                        property: "opacity"
                        from: 0.5
                        to: 1
                        duration: 150
                    }
                    NumberAnimation {
                        target: currentLyric
                        property: "scale"
                        from: 1.08
                        to: 1
                        duration: 250
                        easing.type: Easing.OutBack
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
        } // 🌟 ĐÃ VÁ: Đóng ngoặc nhọn của thẻ lyricsBox

        Connections {
            target: Lyrics
            ignoreUnknownSignals: true
            function onCurrentIndexChanged(){
                Lyrics.displayedIndex = Lyrics.currentIndex
                currentLyric.scale = 1.08
                lyricFade.restart()
            }
            function onCurrentLineChanged(){
                console.log("UI LYRIC:", Lyrics.currentLine)
            }
        }

        Timer {
            id: fadeTimer
            interval: 50
            onTriggered: {
                currentLyric.opacity = 1
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



            // SHUFFLE (TRỘN BÀI - HOVER ĐỔI MÀU STATE CHUẨN)
            Item {
                width: 36
                height: 36

                Text {
                    id: shuffleIcon
                    anchors.centerIn: parent
                    text: "⇄"
                    font.pixelSize: 18

                    // 🎨 BỔ SUNG HOVER: Di chuột vào icon trộn bài sẽ sáng bừng tone màu Album nhạc!
                    color: mouseShuffle.containsMouse ? root.textPrimary : "white"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: mouseShuffle
                    anchors.fill: parent
                    hoverEnabled: true // Bật nhận diện hover chuột
                    onClicked: Players.toggleShuffle()
                }
            }

            // PREVIOUS (BÀI TRƯỚC - HOVER ĐỔI MÀU ACCENT)
            Item {
                width: 36
                height: 36

                Text {
                    id: prevIcon
                    anchors.centerIn: parent
                    text: "⏮"

                    // 🎨 BỔ SUNG HOVER: Di chuột vào sáng nhẹ tone Accent của Album
                    color: mousePrev.containsMouse ? root.accentLight : "white"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: mousePrev
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.player)
                            root.player.previous()
                    }
                }
            }

            // PLAY/PAUSE (PHÁT/TẠM DỪNG - HOVER ĐỔI MÀU CHÍNH)
            Item {
                width: 40
                height: 40

                Text {
                    id: playIcon
                    anchors.centerIn: parent
                    text: Players.isPlaying ? "⏸" : "▶"
                    font.pixelSize: 20

                    // 🎨 BỔ SUNG HOVER: Nút Play/Pause chính tâm rực sáng theo màu Album kích sáng rõ nét
                    color: mousePlay.containsMouse ? root.textPrimary : "white"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: mousePlay
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.player)
                            root.player.togglePlaying()
                    }
                }
            }

            // NEXT (BÀI TIẾP THEO - HOVER ĐỔI MÀU ACCENT)
            Item {
                width: 36
                height: 36

                Text {
                    id: nextIcon
                    anchors.centerIn: parent
                    text: "⏭"

                    // 🎨 BỔ SUNG HOVER: Di chuột vào sáng nhẹ tone Accent của Album
                    color: mouseNext.containsMouse ? root.accentLight : "white"
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: mouseNext
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.player)
                            root.player.next()
                    }
                }
            }




            // LOOP (ĐỒNG BỘ MÀU STATE THEO ALBUM CHUẨN)
            Item {
                width: 36
                height: 36

                Text {
                    id: loopBtn
                    anchors.centerIn: parent
                    text: "↻"
                    font.pixelSize: 18
                    font.bold: true

                    readonly property int mode: {
                        if(!root.player) return 0
                            let id = String(root.player.identity || "").toLowerCase()
                            if(id.includes("tauon")) return Players.tauonLoopState
                                return root.player.loopStatus
                    }

                    // 🎨 SYNC MÀU ICON: Khi bật ăn theo màu Album kích sáng rõ nét, khi tắt giữ màu trắng
                    color: mode > 0 ? root.textPrimary : "white"
                    opacity: mode > 0 ? 1 : 0.45

                    Text {
                        anchors.left: parent.right
                        anchors.leftMargin: -3
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -3

                        text: loopBtn.mode === 1 ? "1" : loopBtn.mode === 2 ? "•" : ""
                        font.pixelSize: loopBtn.mode === 1 ? 9 : 14
                        font.bold: true

                        // 🎨 SYNC MÀU CHỮ PHỤ: Ký tự trạng thái (1 hoặc •) tự lướt màu theo điểm nhấn Album
                        color: root.accentLight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Players.forceToggleLoop()
                }
            }

            // NÚT CÀI ĐẶT LYRICS (BỔ SUNG HOVER ĐỔI MÀU CHO SANG TRỌNG)
            Item {
                width: 36
                height: 36

                Item {
                    width: 36
                    height: 36

                    Text {
                        id: settingIconText
                        anchors.centerIn: parent
                        text: "⚙"

                        // 🎨 BỔ SUNG HOVER MÀU: Di chuột vào bánh răng sẽ sáng bừng tone màu Album nhạc!
                        color: mouseSetting.containsMouse ? root.textPrimary : "white"
                        font.pixelSize: 18

                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MouseArea {
                        id: mouseSetting
                        anchors.fill: parent
                        hoverEnabled: true // Kích hoạt nhận diện chuột hover
                        onClicked: {
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
                model: root.bars.length

                Item {
                    anchors.fill: parent

                    rotation: index * (360 / 48)

                    Rectangle {
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 2

                        width: 2

                        height: Math.min(
                            50,
                            Math.max(
                                4,
                                root.smoothHeights[index] * 1
                            )
                        )

                        radius: 2

                        // 🌟 ĐỒNG BỘ GRADIENT DỌC: Đổ dải màu vuốt mượt từ chân lên ngọn sóng
                        // Cấu trúc khép kín tuyệt đối, không làm thừa thiếu ngoặc gây lệch vị trí Info Block!
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: root.textPrimary }
                            GradientStop { position: 1.0; color: root.accentLight }
                        }
                    }
                }
            }


        }





        Rectangle {
            id: albumBorderCircle

            anchors.centerIn: parent

            width: 110
            height: 110

            radius: 55

            color: "#1a1625"

            border.width: 2

            // 🎨 SYNC MÀU VIỀN ĐĨA: Đổi từ hồng tĩnh sang màu điểm nhấn Album nhạc đã kích sáng
            border.color: root.accentLight



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
            id: progressTrack

            width: parent.width
            height: 4
            radius: 2

            // 🎨 SYNC NỀN RÃNH: Pha mờ màu chính của Album xuống 20% giúp thanh rãnh chìm xuống tinh tế
            color: Qt.rgba(AlbumColors.primary.r, AlbumColors.primary.g, AlbumColors.primary.b, 0.20)

            Rectangle {
                id: progressFill

                height: parent.height
                width: parent.width * root.progress
                radius: 2

                // ❌ ĐÃ LOẠI BỎ thuộc tính color đơn sắc cũ

                // 🌟 GIẢI PHÁP ĐẮT GIÁ: Tích hợp dải loang Gradient ngang phát quang theo tiến trình nhạc
                gradient: Gradient {
                    orientation: Gradient.Horizontal

                    GradientStop {
                        position: 0.0
                        // Điểm bắt đầu (Bên trái): Màu chủ đạo đậm đà của Album nhạc
                        color: root.albumPrimary
                    }

                    GradientStop {
                        position: 1.0
                        // Điểm kết thúc (Đầu vạch chạy bên phải): Màu sáng rực kịch trần tạo hiệu ứng đầu kim phát sáng
                        color: root.textPrimary
                    }
                }
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



            color: root.accentLight



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



            color: root.accentLight



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
        // INFO BLOCK (ĐỒNG BỘ MÀU STATE TÊN BÀI HÁT & NGHỆ SĨ)
        // ========================================================
        ColumnLayout {
            id: middleInfoBlock

            Layout.fillWidth: true
            Layout.preferredHeight: 300
            Layout.topMargin: 1
            Layout.rightMargin: -155

            spacing: 4

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                // 1. DÒNG HIỂN THỊ TÊN BÀI HÁT
                Text {
                    text: root.player ? (root.player.trackTitle || "Unknown Track") : "No Music Playing"
                    font.pixelSize: 14
                    font.bold: true
                    color: "white" // Giữ màu trắng rực rỡ chuẩn chỉ
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                // 2. DÒNG HIỂN THỊ TÊN NGHỆ SĨ (ĐÃ VÁ LỖI ANCHORS)
                Text {
                    text: root.player ? (root.player.trackArtist || "Unknown Artist") : ""
                    font.pixelSize: 11

                    // 🎨 SYNC MÀU: Đổi sang màu xám khói Album đã lọc sáng dịu mắt theo bài hát [0.1]
                    color: root.textSecondary

                    // 🌟 VÁ LỖI BỐ CỤC: Xóa bỏ anchors lộn xộn, dùng Layout alignment chuẩn của ColumnLayout
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Layout.topMargin: 4 // Thu gọn margin từ 20px xuống 4px để hai chữ khít sát nhau tinh tế
                    Layout.preferredWidth: 300
                    elide: Text.ElideRight
                }
            }




            // =====================================================
            // PLAYER SELECTOR
            // =====================================================


            Item {


                width:100

                height:50





                Rectangle {
                    width: 110
                    height: 22

                    x: 360
                    y: -130

                    radius: 6

                    // 🎨 SYNC MÀU NỀN: Ép màu chính của Album mờ 16% tạo hiệu ứng hộp kính mờ cao cấp
                    color: Qt.rgba(AlbumColors.primary.r, AlbumColors.primary.g, AlbumColors.primary.b, 0.16)

                    border.width: 1

                    // 🎨 SYNC MÀU VIỀN: Đổi từ hồng tĩnh sang màu điểm nhấn Album nhạc đã kích sáng
                    border.color: root.accentLight






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
