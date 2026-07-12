import QtQuick
import QtQuick.Layouts

import "../../common"
import "./components"
import "./modules/media"
import "./modules/performance"

// Nạp folder widgets con thông qua alias MyWidgets chống trùng tên hệ thống
import "./widgets" as MyWidgets

Item {
    id: root

    required property var panelWindow
    required property var screenState
    required property real nonAnimWidth

    // BIẾN ĐIỀU PHỐI ĐỒNG BỘ TAB
    property int currentTab: 0

    anchors.fill: parent

    // =========================================================================================
    // 🎯 SIÊU BẢN VÁ: BÀNH TRƯỚC LÒNG KÍNH MẸ (850PX - 400PX) GIẢI CỨU ĐỒ THỊ 100%
    // Phóng đại thênh thang diện tích viền đệm ngoài để cứu toàn bộ thông tin không bị cắt cụt!
    // =========================================================================================
    GlassCard {
        id: unifiedMegaMasterGlass
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20

        color: "#8c110c14"
        border.width: 1
        border.color: "#1affffff"

        // Bề ngang động: Tab 0 (Dashboard) rộng 810px, Tab 1 & 2 BÀNH TRƯỚNG lên hẳn 850px siêu rộng rãi!
        width: root.currentTab === 0 ? 810 : 850

        // Chiều cao động: Tab 0 cao 740px, Tab 1 & 2 DÂNG CAO lên hẳn 400px cho hộp con thở thoải mái!
        height: root.currentTab === 0 ? 740 : 400

        Behavior on width { NumberAnimation { duration: 380; easing.type: Easing.OutQuart } }
        Behavior on height { NumberAnimation { duration: 380; easing.type: Easing.OutQuart } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 14

            // ----------------------------------------------------------------===
            // 🔋 PHẦN GHÉP NỐI 1: THANH TAB VIÊN NHỘNG CHUẨN FILE TAB.QML CỦA BRO
            // ----------------------------------------------------------------===
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 55
                Layout.alignment: Qt.AlignHCenter

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 10

                    property var tabModel: ["Dashboard", "Media", "Performance"]

                    Repeater {
                        model: parent.tabModel

                        delegate: Rectangle {
                            width: 130
                            height: 45
                            radius: 22

                            color: index === root.currentTab ? "#f5c2e7" : "#ff3392"
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: index === root.currentTab ? "#1e1e2e" : "white"
                                font.pixelSize: 15
                                font.weight: Font.Medium
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
                Layout.preferredWidth: parent.width - 40
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
                clip: true // Khóa clip bảo vệ tuyệt đối không cho rò rỉ hình ảnh ra ngoài rìa kính

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
                        height: parent.height
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
        ColumnLayout {
            anchors.fill: parent

            // Giữ nguyên vẹn chiếc vỏ GlassCard con 740x240px chứa đầy đủ sóng nhạc CAVA của bro
            GlassCard {
                Layout.preferredWidth: 760
                Layout.preferredHeight: 240

                // CĂN TÂM HOÀNG GIA: Ghim chuẩn chính giữa lòng kính mẹ 850x400px thênh thang mới,
                // giải phóng khe hở lề biên đệm cực kỳ rộng rãi, bẻ gãy hoàn toàn lỗi cắt chữ mất thông tin!
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.topMargin: 12 // Khoảng đệm trần 12px thoáng mắt siêu sang

                MediaExpanded { anchors.fill: parent }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ==================== COMPONENT PAGE 2: KHUNG CON PERFORMANCE NẰM GỌN GÀNG LỌT TÂM KÍNH MẸ BAO LA ====================
    Component {
        id: performancePage
        ColumnLayout {
            anchors.fill: parent

            // Giữ nguyên vẹn chiếc vỏ GlassCard con 740x240px chứa đầy đủ đồ thị Network và RAM của bro
            GlassCard {
                Layout.preferredWidth: 740
                Layout.preferredHeight: 240

                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.topMargin: 12

                PerformanceExpanded { anchors.fill: parent }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
