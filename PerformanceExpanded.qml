import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root

    anchors.fill: parent

    // --- BIẾN TÊN PHẦN CỨNG THẬT ---
    property string cpuName: "Detecting CPU..."
    property string gpuName: "Detecting GPU..."

    // --- BIẾN CHỈ SỐ HỆ THỐNG THỰC TẾ ---
    property int cpuUsage: 1
    property string cpuTemp: "92"

    property int gpuUsage: 1
    property string gpuTemp: "40"

    property int memPercent: 1
    property string memUsed: "0.0"
    property string memTotal: "0"

    property int storagePercent: 1
    property string storageUsed: "0"
    property string storageTotal: "0"

    // --- CHỈ SỐ BĂNG THÔNG MẠNG THỰC TẾ ---
    property real rawDownBytes: 0
    property real rawUpBytes: 0
    property string netDown: "0.0 KB/s"
    property string netUp: "0.0 KB/s"
    property string netTotal: "↓0.0MB ↑0.0MB"
    property var netHistory: [5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5]

    // TIẾN TRÌNH DÒ TÊN PHẦN CỨNG THẬT
    Process {
        id: hwDetector
        command: ["bash", "-c", "grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed -e 's/^[ \t]*//' | cut -d@ -f1; (nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || lspci | grep -E '(VGA|3D)' | cut -d: -f3 | sed 's/^[ \t]*//' | cut -d'[' -f1) | head -n 1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n");
                if (lines[0]) root.cpuName = lines[0].trim();
                if (lines[1]) root.gpuName = lines[1].trim();
            }
        }
    }

    // 1. TIẾN TRÌNH CPU
    Process {
        id: cpuProcess
        command: ["bash", "-c", "grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print int(usage)}'; (cat /sys/class/hwmon/hwmon*/temp*_input 2>/dev/null | awk '{print $1/1000}' | sort -nr | head -n 1 || sensors 2>/dev/null | grep -E '(Tctl|Tdie|Package id 0|Core 0)' | awk '{print $2}' | tr -d '+°C' | head -n 1)"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n");
                if (lines[0]) root.cpuUsage = Math.min(100, Math.max(1, parseInt(lines[0])));
                if (lines[1]) {
                    let celsius = parseFloat(lines[1]);
                    root.cpuTemp = (isNaN(celsius) || celsius < 10) ? "92" : Math.round(celsius).toString();
                }
            }
        }
    }

    // 2. TIẾN TRÌNH GPU
    Process {
        id: gpuProcess
        command: ["bash", "-c", "if command -v nvidia-smi &> /dev/null; then nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | tr -d ' '; else (cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo '1') && (cat /sys/class/drm/card0/device/hwmon/hwmon*/temp1_input 2>/dev/null | awk '{print $1/1000}' || echo '40'); fi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let raw = text.trim().replace("\n", ","); let parts = raw.split(",");
                if (parts[0]) root.gpuUsage = Math.min(100, Math.max(1, parseInt(parts[0])));
                if (parts[1]) {
                    let celsius = parseFloat(parts[1]);
                    root.gpuTemp = isNaN(celsius) ? "40" : Math.round(celsius).toString();
                }
            }
        }
    }

    // 3. TIẾN TRÌNH RAM
    Process {
        id: memProcess
        command: ["bash", "-c", "free -b | awk 'NR==2{printf \"%d;%.1f;%.1f\", $3/$2*100, $3/1024/1024/1024, $2/1024/1024/1024}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split(";");
                if (parts.length >= 3) {
                    root.memPercent = Math.min(100, Math.max(1, parseInt(parts[0])));
                    root.memUsed = parts[1]; root.memTotal = Math.round(parseFloat(parts[2])).toString();
                }
            }
        }
    }

    // 4. TIẾN TRÌNH STORAGE
    Process {
        id: storageProcess
        command: ["bash", "-c", "df -h / | awk 'NR==2{printf \"%d;%s;%s\", $5, $3, $2}' | tr -d '%'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split(";");
                if (parts.length >= 3) {
                    root.storagePercent = Math.min(100, Math.max(1, parseInt(parts[0])));
                    root.storageUsed = parts[1]; root.storageTotal = parts[2];
                }
            }
        }
    }

    // 5. TIẾN TRÌNH NETWORK
    Process {
        id: netProcess
        command: ["bash", "-c", "awk '{reads+=$2; writes+=$10} END {print reads \";\" writes}' /proc/net/dev"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split(";");
                if (parts.length >= 2) {
                    let currentDown = parseFloat(parts[0]); let currentUp = parseFloat(parts[1]);
                    let totalDownMB = currentDown / 1024 / 1024;
                    let totalUpMB = currentUp / 1024 / 1024;
                    let downStr = totalDownMB > 1024 ? (totalDownMB/1024).toFixed(1) + "GB" : totalDownMB.toFixed(1) + "MB";
                    let upStr = totalUpMB > 1024 ? (totalUpMB/1024).toFixed(1) + "GB" : totalUpMB.toFixed(1) + "MB";
                    root.netTotal = "↓" + downStr + " ↑" + upStr;

                    if (root.rawDownBytes > 0 && root.rawUpBytes > 0) {
                        let diffDown = (currentDown - root.rawDownBytes) / 1024 / 2;
                        let diffUp = (currentUp - root.rawUpBytes) / 1024 / 2;
                        root.netDown = diffDown > 1024 ? (diffDown/1024).toFixed(1) + " MB/s" : diffDown.toFixed(1) + " KB/s";
                        root.netUp = diffUp > 1024 ? (diffUp/1024).toFixed(1) + " MB/s" : diffUp.toFixed(1) + " KB/s";
                        let history = [...root.netHistory];
                        history.shift(); history.push(Math.min(100, Math.max(5, Math.round((diffDown / 150) * 100))));
                        root.netHistory = history;
                        networkCanvas.requestPaint();
                    }
                    root.rawDownBytes = currentDown; root.rawUpBytes = currentUp;
                }
            }
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            cpuProcess.running = false;     cpuProcess.running = true
            gpuProcess.running = false;     gpuProcess.running = true
            memProcess.running = false;     memProcess.running = true
            storageProcess.running = false; storageProcess.running = true
            netProcess.running = false;     netProcess.running = true
        }
    }

    GridLayout {
        anchors.fill: parent; anchors.margins: 12; columns: 3; rowSpacing: 12; columnSpacing: 12

        // ================= CỘT 1 (VẾ TRÁI): CPU TIẾT KIỆM BỀ NGANG VÀ RAM =================
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 8

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 80
                color: "#8c110c14"; radius: 12; border.width: 1; border.color: "#1aff006a"
                RowLayout {
                    anchors.fill: parent; anchors.margins: 10
                    spacing: 6 // Khóa chặt khoảng cách dòng ngang

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true
                        // SỬA ĐỔI QUYẾT ĐỊNH: Nẹp cứng tối đa 120px và bật Elide để tên chip dài tự động viết "..."
                        // Nhường trọn vẹn thềm không gian vế phải cho con số Usage hiện hình!
                        Text { text: "⚙️ CPU - " + root.cpuName; color: "white"; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; Layout.maximumWidth: 120; Layout.fillWidth: true }
                        Text { text: root.cpuTemp + "°C Temp"; color: "#ff006a"; font.pixelSize: 10; font.bold: true }
                        Rectangle { width: 100; height: 4; color: "#22ffffff"; radius: 2; Rectangle { width: parent.width * (root.cpuUsage/100); height: parent.height; color: "#ff006a"; radius: 2 } }
                    }

                    // Khối Usage co cụm cố định dạt phải, không bao giờ lo bị đẩy văng ra ngoài
                    ColumnLayout {
                        Layout.preferredWidth: 45
                        Text { text: "Usage"; color: "#66ffffff"; font.pixelSize: 8; Layout.alignment: Qt.AlignRight }
                        Text { text: root.cpuUsage + "%"; color: "#ff006a"; font.pixelSize: 16; font.bold: true; Layout.alignment: Qt.AlignRight }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 115; color: "#8c110c14"; radius: 12; border.width: 1; border.color: "#1affffff"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 8; spacing: 2
                    Text { text: "💎 Memory"; color: "#F5C2E7"; font.pixelSize: 10; font.bold: true }
                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                let ctx = getContext("2d"); ctx.clearRect(0,0,width,height); ctx.lineWidth = 4;
                                ctx.strokeStyle = "#11ffffff"; ctx.beginPath(); ctx.arc(width/2, height/2, 22, 0, 2*Math.PI); ctx.stroke();
                                ctx.strokeStyle = "#00bfff"; ctx.beginPath(); ctx.arc(width/2, height/2, 22, -Math.PI/2, (-Math.PI/2) + (2*Math.PI*(root.memPercent/100))); ctx.stroke();
                            }
                        }
                        Text { anchors.centerIn: parent; text: root.memPercent + "%"; color: "#00bfff"; font.pixelSize: 13; font.bold: true }
                    }
                    Text { text: root.memUsed + " / " + root.memTotal + " GiB"; color: "#55ffffff"; font.pixelSize: 8; Layout.alignment: Qt.AlignHCenter }
                }
            }
        }

        // ================= CỘT 2 (VẾ GIỮA): GPU TIẾT KIỆM BỀ NGANG VÀ STORAGE =================
        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 8

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 80
                color: "#8c110c14"; radius: 12; border.width: 1; border.color: "#1aEaa850"
                RowLayout {
                    anchors.fill: parent; anchors.margins: 10
                    spacing: 6

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true
                        // SỬA ĐỔI QUYẾT ĐỊNH: Nẹp cứng tối đa 120px tên card đồ họa thực tế của bạn,
                        // bẻ gãy hoàn toàn việc tên card lấn chiếm không gian đẩy lòi chữ % Usage ra ngoài viền kính
                        Text { text: "🖥️ VGA - " + root.gpuName; color: "white"; font.pixelSize: 10; font.bold: true; elide: Text.ElideRight; Layout.maximumWidth: 120; Layout.fillWidth: true }
                        Text { text: root.gpuTemp + "°C Temp"; color: "#Eaa850"; font.pixelSize: 10; font.bold: true }
                        Rectangle { width: 100; height: 4; color: "#22ffffff"; radius: 2; Rectangle { width: parent.width * (root.gpuUsage/100); height: parent.height; color: "#Eaa850"; radius: 2 } }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 45
                        Text { text: "Usage"; color: "#66ffffff"; font.pixelSize: 8; Layout.alignment: Qt.AlignRight }
                        Text { text: root.gpuUsage + "%"; color: "#Eaa850"; font.pixelSize: 16; font.bold: true; Layout.alignment: Qt.AlignRight }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 115; color: "#8c110c14"; radius: 12; border.width: 1; border.color: "#1affffff"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 8; spacing: 2
                    Text { text: "💾 Storage"; color: "white"; font.pixelSize: 10; font.bold: true }
                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                let ctx = getContext("2d"); ctx.clearRect(0,0,width,height); ctx.lineWidth = 4;
                                ctx.strokeStyle = "#11ffffff"; ctx.beginPath(); ctx.arc(width/2, height/2, 22, 0, 2*Math.PI); ctx.stroke();
                                ctx.strokeStyle = "#ffaa00"; ctx.beginPath(); ctx.arc(width/2, height/2, 22, -Math.PI/2, (-Math.PI/2) + (2*Math.PI*(root.storagePercent/100))); ctx.stroke();
                            }
                        }
                        Text { anchors.centerIn: parent; text: root.storagePercent + "%"; color: "#ffaa00"; font.pixelSize: 13; font.bold: true }
                    }
                    Text { text: root.storageUsed + " / " + root.storageTotal; color: "#55ffffff"; font.pixelSize: 8; Layout.alignment: Qt.AlignHCenter }
                }
            }
        }

        // ================= CỘT 3 (VẾ PHẢI): CARD BIỂU ĐỒ MẠNG CANVAS GỌN GÀNG BÊN BIÊN =================
        Rectangle {
            Layout.preferredWidth: 290
            Layout.fillHeight: true
            color: "#8c110c14"; radius: 12; border.width: 1; border.color: "#1a00ffff"

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 4
                Text { text: "↕️ Network Pipeline"; color: "white"; font.pixelSize: 10; font.bold: true }
                Item {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    Canvas {
                        id: networkCanvas; anchors.fill: parent
                        onPaint: {
                            let ctx = getContext("2d"); ctx.clearRect(0, 0, width, height);
                            if (!root.netHistory || root.netHistory.length < 2) return;
                            let step = width / (root.netHistory.length - 1);
                            let grad = ctx.createLinearGradient(0, 0, 0, height);
                            grad.addColorStop(0, "rgba(0, 255, 255, 0.3)"); grad.addColorStop(1, "rgba(0, 255, 255, 0.0)");
                            ctx.beginPath(); ctx.moveTo(0, height);
                            for (let i = 0; i < root.netHistory.length; i++) {
                                let x = i * step; let y = height - (height * (root.netHistory[i] / 100)); ctx.lineTo(x, y);
                            }
                            ctx.lineTo(width, height); ctx.closePath(); ctx.fillStyle = grad; ctx.fill();
                            ctx.beginPath();
                            for (let j = 0; j < root.netHistory.length; j++) {
                                let x2 = j * step; let y2 = height - (height * (root.netHistory[j] / 100));
                                if (j === 0) ctx.moveTo(x2, y2); else ctx.lineTo(x2, y2);
                            }
                            ctx.lineWidth = 1.2; ctx.strokeStyle = "#00ffff"; ctx.stroke();
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 1
                    Text { text: "⬇️ Down: " + root.netDown; color: "#00ffff"; font.pixelSize: 9; font.bold: true }
                    Text { text: "⬆️ Up:   " + root.netUp; color: "#ff006a"; font.pixelSize: 9; font.bold: true }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#22ffffff"; Layout.topMargin: 2 }
                    Text { text: "Total Data Usage"; color: "#44ffffff"; font.pixelSize: 7; Layout.topMargin: 1 }
                    Text { text: root.netTotal; color: "white"; font.pixelSize: 9; font.bold: true }
                }
            }
        }
    }
}
