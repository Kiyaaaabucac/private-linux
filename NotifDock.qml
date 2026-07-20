import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../../../services"


Item {
    id: notifRoot

    implicitWidth: 340
    implicitHeight: 400

    property color albumPrimary: AlbumColors.primary
    property color textPrimary: Qt.lighter(albumPrimary, 3.0)
    property color accentLight: Qt.lighter(albumPrimary, 1.5)
    Behavior on albumPrimary { ColorAnimation { duration: 500 } }


    // BỆ ĐỠ TỔNG: Hộp kính mờ phẳng lỳ đen bóng đêm 45%
    Rectangle {
        anchors.fill: parent
        radius: 22
        color: Qt.rgba(11 / 255, 9 / 255, 17 / 255, 0.45)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // =========================================================================
            // 📊 THANH TIÊU ĐỀ ĐẦU NÃO (HEADER DOCK)
            // =========================================================================
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: localNotifModel.count > 0 ? "🔔" : "🔕"
                    font.pixelSize: 12
                }

                Text {
                    text: localNotifModel.count + " NOTIFICATIONS"
                    color: localNotifModel.count > 0 ? notifRoot.textPrimary : "#A6ADC8"
                    font.pixelSize: 11
                    font.bold: true
                    opacity: localNotifModel.count > 0 ? 0.9 : 0.5
                    font.family: "JetBrains Mono"
                    style: Text.Normal
                }

                Item { Layout.fillWidth: true }

                // NÚT CLEAR ALL PHẲNG NGHỆ THUẬT
                Rectangle {
                    id: clearAllBtn
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 24
                    radius: 8
                    color: clearAllMouse.containsMouse ? Qt.rgba(AlbumColors.primary.r, AlbumColors.primary.g, AlbumColors.primary.b, 0.15) : "transparent"
                    border.width: 1

                    // 🌟 SỬA LỖI CHÍ MẠNG: Điền lại thuộc tính border.color: bị mất ở đây!
                    border.color: clearAllMouse.containsMouse ? notifRoot.textPrimary : Qt.rgba(1, 1, 1, 0.1)

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "CLEAR ALL"
                        color: clearAllMouse.containsMouse ? "white" : notifRoot.textPrimary
                        font.pixelSize: 9
                        font.bold: true
                        font.family: "JetBrains Mono"
                        style: Text.Normal
                    }

                    MouseArea {
                        id: clearAllMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: localNotifModel.clear()
                    }
                }
            }

            // =========================================================================
            // 📥 DANH SÁCH LƯỚT CUỘN THÔNG BÁO (LISTVIEW MANAGEMENT)
            // =========================================================================
            ListView {
                id: notifListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10
                clip: true

                model: localNotifModel

                // Trạng thái trống trơn (Không có thông báo nào)
                Rectangle {
                    anchors.fill: parent
                    visible: localNotifModel.count === 0
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.02)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.04)

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "📥"; font.pixelSize: 22; Layout.alignment: Qt.AlignHCenter; opacity: 0.3 }
                        Text {
                            text: "No new notifications"
                            color: "#A6ADC8"
                            opacity: 0.4
                            font.pixelSize: 11
                            font.family: "JetBrains Mono"
                            Layout.alignment: Qt.AlignHCenter
                            style: Text.Normal
                        }
                    }
                }

                // KHỐI THÔNG BÁO CON TRƯỢT LƯỚT CHÍNH (DELEGATE)
                delegate: Rectangle {
                    id: itemCard
                    width: notifListView.width
                    height: 56 // Tăng lên 56px ôm khít hoàn hảo dải Icon
                    radius: 14
                    color: Qt.rgba(255/255, 255/255, 255/255, 0.04)
                    border.width: 1
                    border.color: itemMouse.containsMouse ? notifRoot.accentLight : Qt.rgba(1,1,1,0.06)

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // Accent Line: Dải vách màu hồng Neon bên cánh trái
                        Rectangle {
                            width: 3
                            Layout.fillHeight: true
                            radius: 1.5
                            color: notifRoot.accentLight
                        }

                        // =========================================================================
                        // 🎨 ĐỘT PHÁ ĐỒ HỌA: KHUNG CHỨA APP ICON XỊN MỊN chuẩn Linux Theme
                        // =========================================================================
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.1)
                            clip: true
                            Layout.alignment: Qt.AlignVCenter

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2

                                // Tự động dò kho icon hệ thống dựa trên tên appIcon nhận về (Spotify, Discord...)
                                source: model.iconSource ? "image://icon/" + model.iconSource : ""
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true

                                // Bộ nạp ảnh dự phòng nếu ứng dụng không có icon hệ thống chuẩn
                                Text {
                                    anchors.centerIn: parent
                                    text: "💬"
                                    font.pixelSize: 14
                                    visible: parent.status !== Image.Ready
                                }
                            }
                        }

                        // Tên ứng dụng viết Hoa đậm đà thương hiệu
                        Text {
                            text: model.appName
                            color: notifRoot.accentLight
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "JetBrains Mono"
                            Layout.preferredWidth: 45
                            elide: Text.ElideRight
                            style: Text.Normal
                        }

                        // Vách ngăn chia mờ tinh tế
                        Rectangle {
                            width: 1
                            Layout.fillHeight: true
                            color: Qt.rgba(1, 1, 1, 0.1)
                        }

                        // KHỐI HIỂN THỊ CHỮ SIÊU PHẲNG SAO SẠCH CHỮ ĐEN
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: model.summary
                                color: "#FFFFFF"
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "JetBrains Mono"
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                                style: Text.Normal
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model.body
                                color: "#C3BAC6"
                                font.pixelSize: 10
                                opacity: 0.8
                                font.family: "JetBrains Mono"
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                                style: Text.Normal
                            }
                        }

                        // NÚT DISMISS XÓA NHANH TỪNG TIN NHẮN CON
                        Rectangle {
                            id: dismissBtn
                            width: 18
                            height: 18
                            radius: 4
                            color: dismissMouse.containsMouse ? Qt.rgba(255/255, 255/255, 255/255, 0.1) : "transparent"
                            opacity: itemMouse.containsMouse ? 0.7 : 0.0

                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: dismissMouse.containsMouse ? notifRoot.textPrimary : "#A6ADC8"
                                font.pixelSize: 14
                                font.bold: true
                                // Vùng rình chuột cho toàn bộ tấm thẻ thông báo con
                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    propagateComposedEvents: true
                                }
                            }
                        }
                    }
                }

                // =========================================================================
                // 🧠 TỔNG ĐÀI CÀO D-BUS DỮ LIỆU (SỬA LỖI ĐÓNG NGOẶC - ĐÃ THÊM LUỒNG ICON XỊN)
                // =========================================================================
                ListModel {
                    id: localNotifModel
                }

                NotificationServer {
                    id: internalServer

                    onNotification: (notif) => {
                        let rawSummary = String(notif.summary || "Notification")
                        let rawBody = String(notif.body || "")

                        let cleanSummary = rawSummary.replace(/<\/?[^>]+(>|$)/g, "")
                        let cleanBody = rawBody.replace(/<\/?[^>]+(>|$)/g, "")

                        // Lấy tên định danh icon ứng dụng gốc (ví dụ: "spotify", "discord")
                        let appIconName = String(notif.appIcon || notif.appName || "").toLowerCase()

                        localNotifModel.insert(0, {
                            "appName": String(notif.appName || "SYS").toUpperCase(),
                                               "summary": cleanSummary,
                                               "body": cleanBody,
                                               "iconSource": appIconName // Gieo tên icon sòng phẳng vào Model con [1.1]
                        })

                        // Bảo toàn bộ lọc giới hạn ép trần tối đa 2 thông báo để không làm nẩy layout
                        while (localNotifModel.count > 2) {
                            localNotifModel.remove(localNotifModel.count - 1)
                        }
                    } // <-- Chốt đóng hàm onNotification sòng phẳng của Quickshell
                } // <-- Chốt đóng thẻ NotificationServer sạch sẽ, cấm tuyệt đối viết rác ra ngoài!
            } // <-- Chốt đóng toàn bộ file gốc Item ngoài cùng (notifRoot) của bạn
        }
    }
}
