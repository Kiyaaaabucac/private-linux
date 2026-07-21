import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import "../../common"
import "./components"
import "./modules/media"
import "./modules/performance"
import "../../services"

// Nạp folder widgets con thông qua alias MyWidgets chống trùng tên hệ thống
import "./widgets" as MyWidgets

Item {
    id: root

    required property var panelWindow
    required property var screenState
    required property real nonAnimWidth

    // 🧠 BỘ LỌC ĐA SẮC ĐỘNG (ALBUM COLOR STATE MATRIX - ĐỒNG BỘ CHO TOÀN BỘ CÁC TAB)
    property color albumPrimary: AlbumColors.primary
    property color textPrimary: Qt.lighter(albumPrimary, 3.0)
    property color accentLight: Qt.lighter(albumPrimary, 1.5)
    Behavior on albumPrimary { ColorAnimation { duration: 500 } }

    // BIẾN ĐIỀU PHỐI ĐỒNG BỘ TAB
    property int currentTab: 0

    anchors.fill: parent

    // Tải font Anurati nghệ thuật làm tài nguyên cục bộ cho khay Tab
    FontLoader {
        id: anuratiFont
        source: "./Anurati-Regular.otf"
    }

    // =========================================================================================
    // 🎯 SIÊU BẢN VÁ: BÀNH TRƯỚC LÒNG KÍNH MẸ (850PX - 400PX) GIẢI CỨU ĐỒ THỊ 100%
    // =========================================================================================
    GlassCard {
        id: unifiedMegaMasterGlass
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20

        color: "#8c110c14"
        border.width: 1
        border.color: "#1affffff"

        width: root.currentTab === 0 ? 810 : 810
        height: root.currentTab === 0 ? 530 : 400

        Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutQuart } }
        Behavior on height { NumberAnimation { duration: 260; easing.type: Easing.OutQuart } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 14

            // ----------------------------------------------------------------===
            // 🔋 PHẦN GHÉP NỐI 1: THANH TAB VIÊN NHỘNG (ĐÃ ĐỒNG BỘ MÀU CHUNG 100%)
            // ----------------------------------------------------------------===
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 55
                Layout.alignment: Qt.AlignHCenter

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    property var tabModel: ["Poor Man", "Vinnahouse", "My Potato"]

                    Repeater {
                        model: parent.tabModel

                        delegate: Rectangle {
                            width: 130
                            height: 45
                            radius: 22

                            // 🎯 ĐÃ ĐỒNG BỘ MÀU NỀN: Tất cả các Tab khi được chọn hoặc chờ đều bám khít màu hệ thống bài hát
                            color: {
                                if (index === root.currentTab) {
                                    return root.textPrimary; // Khi được chọn: Hiện màu sáng rực rỡ kịch trần
                                } else {
                                    return Qt.rgba(AlbumColors.primary.r, AlbumColors.primary.g, AlbumColors.primary.b, 0.25); // Khi chờ: Đồng bộ nền mờ kính 25% màu Album
                                }
                            }
                            Behavior on color { ColorAnimation { duration: 200 } }

                            Canvas {
                                id: tabTextCanvas
                                anchors.fill: parent

                                Connections {
                                    target: root
                                    function onCurrentTabChanged() { tabTextCanvas.requestPaint() }
                                    function onTextPrimaryChanged() { tabTextCanvas.requestPaint() }
                                }

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();

                                    ctx.font = "bold 13px '" + anuratiFont.name + "'";
                                    ctx.textAlign = "center";
                                    ctx.textBaseline = "middle";

                                    // Giữ nguyên khoảng cách chữ Cinematic rộng mở của bạn
                                    ctx.letterSpacing = "20px";

                                    var txt = modelData.toUpperCase();

                                    // 🎯 ĐÃ ĐỒNG BỘ HOÀN TOÀN BIẾN ĐỔI CHỮ CHO CẢ 3 TAB
                                    // CHẾ ĐỘ 1: KHI ĐANG Ở TRONG TAB (ĐƯỢC CHỌN)
                                    if (index === root.currentTab) {
                                        // Hào quang phát sáng Neon dịu nhẹ bao quanh toàn bộ chữ của cả 3 Tab
                                        ctx.shadowColor = root.accentLight;
                                        ctx.shadowBlur = 8;
                                        ctx.shadowOffsetX = 0;
                                        ctx.shadowOffsetY = 0;

                                        // Ruột chữ chuyển màu Gradient chéo ngang mượt mà bám sát CAVA
                                        var grad = ctx.createLinearGradient(0, 0, width, 0);
                                        grad.addColorStop(0.0, root.textPrimary);
                                        grad.addColorStop(1.0, root.accentLight);
                                        ctx.fillStyle = grad;

                                        // Vẽ ruột chữ loang màu nghệ thuật
                                        ctx.fillText(txt, width / 2, height / 2);

                                        // Đổ thêm viền đen sẫm sắc nét bọc ngoài nét cắt font Anurati chống rách hình
                                        ctx.shadowBlur = 0;
                                        ctx.strokeStyle = "#16111a";
                                        ctx.lineWidth = 1.4;
                                        ctx.strokeText(txt, width / 2, height / 2);
                                    }
                                    // CHẾ ĐỘ 2: TRẠNG THÁI CHỜ (KHÔNG ĐƯỢC CHỌN)
                                    else {
                                        ctx.shadowBlur = 0;
                                        if (index === 1) {
                                            ctx.fillStyle = root.textPrimary; // Khôi phục chữ Vinnahouse màu sáng nhạc
                                        } else {
                                            ctx.fillStyle = "white";
                                        }
                                    }

                                    // Vẽ chữ phẳng cho các tab còn lại
                                    ctx.fillText(txt, width / 2, height / 2);
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { root.currentTab = index }
                            }
                        }
                    }
                }
            }

            // Đường chỉ phân cách Neon chạy xuyên lòng kính Master
            Rectangle {
                Layout.preferredWidth: parent.width - 30
                Layout.preferredHeight: 1
                color: "#ff006a"
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.25
            }


            // ----------------------------------------------------------------===
            // 🎞️ KHỐI CHỨA TRƯỢT SLIDE: KHÓA CHẾ CỐ ĐỊNH PHÉP DỊCH 790PX TUYỆT ĐỐI CHỐNG LỘ LỀ TAB KHÁC
            // ----------------------------------------------------------------===
            Item {
                id: contentContainer
                // 🎯 KHÓA TỌA ĐỘ VÀNG: Ép bề ngang thềm slide cố định 790px cho tất cả các Tab,
                // triệt tiêu hoàn toàn lỗi dịch chuyển phân sai làm lộ viền của tab kế bên!
                Layout.preferredWidth: 790
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                clip: true
                // Khóa clip bảo vệ tuyệt đối không cho rò rỉ hình ảnh ra ngoài rìa kính

                Row {
                    id: slidingRow
                    height: parent.height
                    x: 0

                    transform: Translate {
                        id: translateTransform
                        // Nhân mốc dịch chuyển bất biến 790px, cam kết lướt dứt khoát dạt hẳn qua biên 100%!
                        x: -(root.currentTab * 790)

                        Behavior on x {
                            NumberAnimation {
                                duration: 380
                                easing.type: Easing.OutQuart
                            }
                        }
                    }

                    // KHỐI TAB 0 (DASHBOARD TO RỘNG CĂN TRONG LÒNG 790PX)
                    Item {
                        width: 780
                        height: parent.height
                        Loader { anchors.fill: parent; sourceComponent: dashPage }
                    }

                    // KHỐI TAB 1 (MEDIA RỘNG LỌT TÂM 790PX)
                    Item {
                        width: 790
                        height:parent.height
                        Loader { anchors.fill: parent; sourceComponent: mediaPage }
                    }

                    // KHỐI TAB 2 (PERFORMANCE RỘNG LỌT TÂM 790PX)
                    Item {
                        width: 790
                        height: parent.height
                        Loader { anchors.fill: parent; sourceComponent: performancePage }
                    }
                }
            }
        }
    }

    // ==================== COMPONENT PAGE 0: VÁ TRÚNG PHÓC LỖI FETCH TRÀO CHỮ VÀ MUSIC LỆCH PHẢI ====================
    Component {
        id: dashPage

        RowLayout {
            id: mainLayout
            anchors.fill: parent
            // Siết chặt khoảng cách giữa 3 cột đúng 12px để nhường trọn vẹn thềm ngang cho Fetch thở
            spacing: 12
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            // --- CỘT 1: THỜI TIẾT & ĐỒNG HỒ DỌC (NẸP CHẶT CỐ ĐỊNH) ---
            ColumnLayout {
                Layout.preferredWidth: 150
                Layout.maximumWidth: 150
                Layout.fillHeight: true
                spacing: 10

                GlassCard {
                    Layout.fillWidth: true; Layout.preferredHeight: 105
                    MyWidgets.Weather { anchors.fill: parent }
                }

                GlassCard {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    MyWidgets.Clock { anchors.fill: parent }
                }
            }

            // --- CỘT 2: SYSTEM FETCH & LỊCH KẾT HỢP (KHÓA CỨNG 390PX CHỐNG TRÀO CHỮ 100%) ---
            ColumnLayout {
                // ÉP CHIỀU RỘNG TUYỆT ĐỐI: Khóa cứng 390px triệt tiêu hoàn toàn lực bóp nghẹt layout,
                // giúp Avatar lớn và mảng chữ 12px-14px của Fetch nằm ngay ngắn, lọt lòng kính con!
                Layout.preferredWidth: 390
                Layout.maximumWidth: 390
                Layout.fillHeight: true
                spacing: 10

                GlassCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 125
                    MyWidgets.Fetch { anchors.fill: parent }
                }

                GlassCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 10
                        Item { Layout.fillWidth: true; Layout.fillHeight: true; Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter; MyWidgets.Calendar { anchors.fill: parent } }
                        Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 70; Layout.alignment: Qt.AlignVCenter; color: "#ff006a"; opacity: 0.25 }
                        Item { Layout.preferredWidth: 85; Layout.fillHeight: true; Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter; MyWidgets.System { anchors.fill: parent } }
                    }
                }
            }

            // --- CỘT 3: TRÌNH PHÁT NHẠC ĐĨA XOAY (GIẬT LÙI SANG TRÁI CHỐNG LỆCH PHẢI) ---
            ColumnLayout {
                // KHÓA CHIỀU RỘNG VÀNG: Thu hẹp về đúng 210px để đĩa nhạc ôm sát khít lòng kính
                Layout.preferredWidth: 210
                Layout.maximumWidth: 210
                Layout.fillHeight: true
                spacing: 10

                // 🎯 LỰC ÉP BIÊN CHỐT HẠ: Thêm lề phải dương để kéo chiếc hộp Music dịch chuyển tịnh tiến
                // nhích sang vế bên trái một tí, bẻ gãy hoàn toàn tình trạng bị đẩy dính sát vào tường kính phải!
                Layout.rightMargin: 12

                GlassCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    MyWidgets.Music { anchors.fill: parent }
                }
            }
        }
    }


    // ==================== COMPONENT PAGE 1: KHUNG CON MEDIA NẰM GỌN GÀNG LỌT TÂM KÍNH MẸ BAO LA ====================
    Component {
        id: mediaPage


        Item {

            anchors.fill: parent



            // =====================
            // MEDIA CARD
            // =====================

            GlassCard {

                id:mediaCard


                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top


                anchors.topMargin:12


                clip:true


                width:parent.width-40
                height:parent.height-11




                MediaExpanded {

                    anchors.fill:parent



                    onOpenLyricsSettings:{


                        console.log(
                            "OPEN LYRICS FROM MEDIA"
                        )


                        if(lyricsSettingsLoader.item)
                        {

                            lyricsSettingsLoader.item.open()

                        }


                        else
                        {

                            lyricsSettingsLoader.active=true


                            Qt.callLater(()=>{


                                if(lyricsSettingsLoader.item)
                                {

                                    lyricsSettingsLoader.item.open()

                                }


                            })


                        }


                    }


                }


            }

        }

    }


    // =====================
    // LYRICS SETTINGS OVERLAY
    // OUTSIDE MEDIA CARD
    // =====================


    Item {

        id:overlayLayer

        anchors.fill:parent

        z:9999



        Loader {

            id:lyricsSettingsLoader


            width:200
            height:550


            anchors.right:parent.right
            anchors.top:parent.top


            anchors.rightMargin:350
            anchors.topMargin:20



            active:true


            source:
            "./modules/media/LyricsSettings.qml"



            onLoaded:{


                item.width=width

                item.height=height


                console.log(
                    "LYRICS SIZE:",
                    item.width,
                    item.height
                )


            }


        }


    }

    // ==================== COMPONENT PAGE 2: KHUNG CON PERFORMANCE NẰM GỌN GÀNG LỌT TÂM KÍNH MẸ BAO LA ====================
    Component {
        id: performancePage
        ColumnLayout {
            anchors.fill: parent

            // Giữ nguyên vẹn chiếc vỏ GlassCard con 740x240px chứa đầy đủ đồ thị Network và RAM của bro
            GlassCard {
                Layout.preferredWidth: 730
                Layout.preferredHeight: 240
                Layout.rightMargin: 1


                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.topMargin: 12

                PerformanceExpanded { anchors.fill: parent }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
