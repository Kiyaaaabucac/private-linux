pragma Singleton

import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpuUsage: 0
    property real ramUsage: 0
    property real temperature: 0

    // =========================================================================
    // ↕️ MA TRẬN LƯU TRỮ BĂNG THÔNG MẠNG (ĐỒNG BỘ 100% THEO PERFORMANCEEXPANDED)
    // =========================================================================
    property string netDown: "0.0 KB/s"
    property string netUp: "0.0 KB/s"
    property string netTotal: "↓0.0MB ↑0.0MB"

    // Bộ nhớ RAM lưu trữ bytes thô của 2 giây trước để làm phép tính trừ Delta
    property real rawDownBytes: 0
    property real rawUpBytes: 0

    // Mảng lưu trữ 20 điểm dữ liệu để vẽ biểu đồ sóng mạng nhấp nhô (nếu có Canvas)
    property var netHistory: [5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5]

    // Biến tĩnh phẳng lưu dung lượng pin cào thô từ nhân Linux của bạn
    property real batteryPercentage: 0.85
    property bool batteryIsCharging: false

    Timer {
        interval: 2000 // Chu kỳ quét đúng 2 giây trùng khít với Dashboard của bạn
        running: true
        repeat: true

        onTriggered: {
            cpuProcess.running = false; cpuProcess.running = true
            ramProcess.running = false; ramProcess.running = true
            tempProcess.running = false; tempProcess.running = true

            // Kích hoạt luồng cào mạng thô và pin thô đồng thì
            netProcess.running = false; netProcess.running = true
            batCapacityProcess.running = false; batCapacityProcess.running = true
            batStatusProcess.running = false;   batStatusProcess.running = true
        }
    }

    // =========================================================================
    // ↕️ TIẾN TRÌNH CÀO MẠNG NATIVE GỐC (BẢO TOÀN NGUYÊN BẢN CỦA BẠN)
    // Cào số bytes thô cực nhẹ máy, nhường trọn vẹn phép tính chia cho JavaScript QML
    // =========================================================================
    Process {
        id: netProcess
        command: ["bash", "-c", "awk '{reads+=$2; writes+=$10} END {print reads \";\" writes}' /proc/net/dev"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split(";");
                if (parts.length >= 2) {
                    let currentDown = parseFloat(parts[0]);
                    let currentUp = parseFloat(parts[1]);

                    if (isNaN(currentDown) || isNaN(currentUp)) return;

                    let totalDownMB = currentDown / 1024 / 1024;
                    let totalUpMB = currentUp / 1024 / 1024;

                    let downStr = totalDownMB > 1024 ? (totalDownMB/1024).toFixed(1) + "GB" : totalDownMB.toFixed(1) + "MB";
                    let upStr = totalUpMB > 1024 ? (totalUpMB/1024).toFixed(1) + "GB" : totalUpMB.toFixed(1) + "MB";
                    root.netTotal = "↓" + downStr + " ↑" + upStr;

                    // THUẬT TOÁN TÍNH TỐC ĐỘ DELTA KHƠI THÔNG DÒNG MẠNG CHÍ MẠNG
                    if (root.rawDownBytes > 0 && root.rawUpBytes > 0) {
                        // Chia cho 2 vì chu kỳ Timer của bạn quét là 2 giây một lần
                        let diffDown = (currentDown - root.rawDownBytes) / 1024 / 2;
                        let diffUp = (currentUp - root.rawUpBytes) / 1024 / 2;

                        root.netDown = diffDown > 1024 ? (diffDown/1024).toFixed(1) + " MB/s" : diffDown.toFixed(1) + " KB/s";
                        root.netUp = diffUp > 1024 ? (diffUp/1024).toFixed(1) + " MB/s" : diffUp.toFixed(1) + " KB/s";

                        // Đồng bộ mảng lịch sử sóng mạng nhấp nhô
                        let history = [...root.netHistory];
                        history.shift();
                        history.push(Math.min(100, Math.max(5, Math.round((diffDown / 150) * 100))));
                        root.netHistory = history;
                    }

                    // Ghim lại số bytes hiện tại vào bộ nhớ RAM để làm mốc trừ cho 2 giây kế tiếp
                    root.rawDownBytes = currentDown;
                    root.rawUpBytes = currentUp;
                }
            }
        }
    }

    // 🔋 TIẾN TRÌNH CÀO % PIN TỪ KHAY CỨNG BAT0
    Process {
        id: batCapacityProcess
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo '85'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let p = parseInt(text.trim());
                if (!isNaN(p) && p >= 0) root.batteryPercentage = p / 100;
            }
        }
    }

    // ⚡ TIẾN TRÌNH CÀO TRẠNG THÁI SẠC PIN
    Process {
        id: batStatusProcess
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo 'Discharging'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let s = text.trim().toLowerCase();
                root.batteryIsCharging = (s.includes("charging") || s.includes("full"));
            }
        }
    }

    Process {
        id: cpuProcess
        command: ["bash", "-c", "awk '/cpu / {usage=($2+$4)*100/($2+$4+$5); print usage}' /proc/stat | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                let value = Number(text.trim())
                if (!isNaN(value) && value >= 0) root.cpuUsage = value
            }
        }
    }

    Process {
        id: ramProcess
        command: ["bash", "-c", "free | awk '/Mem/ {printf \"%d\",$3/$2*100}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let value = Number(text.trim())
                if (!isNaN(value) && value >= 0) root.ramUsage = value
            }
        }
    }

    Process {
        id: tempProcess
        command: ["bash", "-c", "sensors 2>/dev/null | awk '/Package id 0/ {print $4}' | tr -d '+°C'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let value = Number(text.trim())
                if (!isNaN(value) && value >= 0) root.temperature = value
            }
        }
    }
}
