import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root

    // Tự động co giãn khít khao 100% theo lòng ô GlassCard con của Dashboard
    anchors.fill: parent

    property int volumeVal: 65
    property int brightnessVal: 45
    property int batteryVal: 85

    // Biến khóa an toàn cô lập trạng thái tương tác kéo trượt của bro
    property bool isUserInteracting: false

    // 1. TIẾN TRÌNH CÀO ÂM LƯỢNG HỆ THỐNG
    Process {
        id: volProcess
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2*100}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let v = parseInt(text.trim());
                if (!root.isUserInteracting) {
                    root.volumeVal = isNaN(v) ? 65 : Math.min(100, Math.max(0, v));
                }
            }
        }
    }

    // =========================================================================================
    // 🎯 KHÔI PHỤC ĐẮT GIÁ 1: Trở lại lệnh brightnessctl bốc % độ sáng thực tế của màn hình Laptop
    // Lệnh này bóc tách chuẩn xác dòng số thực tại từ hệ thống, chạy mượt mà không lo lag máy!
    // =========================================================================================
    Process {
        id: brightProcess
        command: ["bash", "-c", "brightnessctl -m | awk -F, '{print $4}' | tr -d '%' || echo '45'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let b = parseInt(text.trim());
                if (!root.isUserInteracting && !cooldownTimer.running) {
                    root.brightnessVal = isNaN(b) ? 45 : Math.min(100, Math.max(0, b));
                }
            }
        }
    }

    // 3. TIẾN TRÌNH CÀO DUNG LƯỢNG PIN LAPTOP VOSTRO
    Process {
        id: batProcess
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT0/capacity"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let p = parseInt(text.trim());
                if (!root.isUserInteracting) {
                    root.batteryVal = isNaN(p) ? 85 : Math.min(100, Math.max(0, p));
                }
            }
        }
    }

    // Khai báo các lệnh thực thi xuất tín hiệu ra hệ thống phần cứng
    Process { id: setVolCmd }
    Process { id: setBrightCmd }

    // Bộ Timer tự động làm mới chỉ số sau mỗi 3 giây (Tự ngắt chạy khi bro đang kéo slider)
    Timer {
        id: hardwareScannerTimer
        interval: 3000
        running: !root.isUserInteracting && !cooldownTimer.running
        repeat: true
        onTriggered: {
            volProcess.running = false;    volProcess.running = true
            brightProcess.running = false; brightProcess.running = true
            batProcess.running = false;    batProcess.running = true
        }
    }

    // Bộ Timer đệm đóng băng hệ thống 1.5 giây sau khi thả tay cho mượt vạch trượt
    Timer {
        id: cooldownTimer
        interval: 1500
        repeat: false
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 14
        Layout.alignment: Qt.AlignHCenter

        // --- CỘT DỌC 1: TRƯỢT ÂM LƯỢNG (INTERACTIVE VOLUME SLIDER) ---
        ColumnLayout {
            Layout.fillHeight: true; spacing: 6; Layout.alignment: Qt.AlignHCenter
            Rectangle {
                id: vBarBg; width: 14; Layout.fillHeight: true; radius: 7; color: "#110c14"; border.width: 1; border.color: "#3d1b32"
                Rectangle { id: vFill; anchors.bottom: parent.bottom; width: parent.width; radius: parent.radius; color: "#ff006a"; height: parent.height * (root.volumeVal / 100); Behavior on height { NumberAnimation { duration: 100 } } }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onPressed: (mouse) => { root.isUserInteracting = true; updateVolume(mouse.y); }
                    onPositionChanged: (mouse) => { if (pressed) updateVolume(mouse.y); }
                    onReleased: { root.isUserInteracting = false; }
                    function updateVolume(mouseY) {
                        let percentage = Math.min(100, Math.max(0, Math.round((1 - (mouseY / vBarBg.height)) * 100)));
                        root.volumeVal = percentage;
                        setVolCmd.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (percentage / 100)];
                        setVolCmd.running = false; setVolCmd.running = true;
                    }
                }
            }
            Text { Layout.alignment: Qt.AlignHCenter; text: "🔊"; font.pixelSize: 12; color: "#F5C2E7" }
            Text { Layout.alignment: Qt.AlignHCenter; text: root.volumeVal + "%"; color: "white"; font.pixelSize: 8; opacity: 0.5 }
        }

        // --- CỘT DỌC 2: TRƯỢT ĐỘ SÁNG MÀN HÌNH LAPTOP CHUẨN MỰC GỐC AN TOÀN TUYỆT ĐỐI ---
        ColumnLayout {
            Layout.fillHeight: true
            spacing: 6
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                id: bBarBg
                width: 14
                Layout.fillHeight: true
                radius: 7
                color: "#110c14"
                border.width: 1
                border.color: "#3d1b32"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    radius: parent.radius
                    color: "#F5C2E7"
                    height: parent.height * (root.brightnessVal / 100)
                    Behavior on height { NumberAnimation { duration: 80 } }
                }

                // CƠ CHẾ KÉO TRƯỢT ĐỘ SÁNG LAPTOP MƯỢT MÀ CHUẨN XÁC
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: (mouse) => {
                        cooldownTimer.stop();
                        root.isUserInteracting = true;
                        calculatePercentage(mouse.y);
                    }

                    onPositionChanged: (mouse) => {
                        if (pressed) {
                            calculatePercentage(mouse.y);
                        }
                    }

                    // 🎯 KHÔI PHỤC QUYẾT ĐỊNH: Thả tay ra gọi trực tiếp lệnh brightnessctl thô của hệ thống
                    // Trả lại luồng chạy mượt mà, ăn lệnh tăng giảm ánh sáng màn hình laptop Vostro lập tức 100%!
                    onReleased: (mouse) => {
                        cooldownTimer.start();
                        root.isUserInteracting = false;

                        setBrightCmd.command = ["bash", "-c", "brightnessctl set " + root.brightnessVal + "%"];
                        setBrightCmd.running = false; setBrightCmd.running = true;
                    }

                    function calculatePercentage(mouseY) {
                        let percentage = Math.min(100, Math.max(1, Math.round((1 - (mouseY / bBarBg.height)) * 100)));
                        root.brightnessVal = percentage;
                    }
                }
            }

            Text { Layout.alignment: Qt.AlignHCenter; text: "☀️"; font.pixelSize: 12; color: "#F5C2E7" }
            Text { Layout.alignment: Qt.AlignHCenter; text: root.brightnessVal + "%"; color: "white"; font.pixelSize: 8; opacity: 0.5 }
        }

        // --- CỘT DỌC 3: DUNG LƯỢNG PIN LAPTOP CHỈ HIỂN THỊ ---
        ColumnLayout {
            Layout.fillHeight: true; spacing: 6; Layout.alignment: Qt.AlignHCenter
            Rectangle {
                id: batBarBg; width: 12; Layout.fillHeight: true; radius: 6; color: "#110c14"; border.width: 1; border.color: "#3d1b32"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; radius: parent.radius; color: "#ff006a"; height: parent.height * (root.batteryVal / 100); Behavior on height { NumberAnimation { duration: 200 } } }
            }
            Text { Layout.alignment: Qt.AlignHCenter; text: "🔋"; font.pixelSize: 12; color: "#F5C2E7" }
            Text { Layout.alignment: Qt.AlignHCenter; text: root.batteryVal + "%"; color: "white"; font.pixelSize: 8; opacity: 0.5 }
        }
    }
}
