pragma Singleton

import QtQml
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Biến cờ động điều khiển trạng thái ẩn/hiện của đồng hồ nền ngoài desktop
    property bool visible: true

    function open() {
        root.visible = true
        console.log("[CLOCK SERVICE] ĐỒNG HỒ ĐÃ ĐƯỢC BẬT CHẠY REALTIME")
    }

    function close() {
        root.visible = false
        console.log("[CLOCK SERVICE] ĐỒNG HỒ ĐÃ ĐƯỢC TẮT GIẢI PHÓNG TÀI NGUYÊN")
    }

    function toggle() {
        root.visible = !root.visible
        console.log("[CLOCK SERVICE] CHUYỂN TRẠNG THÁI ĐỒNG HỒ THÀNH: " + root.visible)
    }

    // 🌟 BỘ NHẬN LỆNH IPC TRỰC TIẾP TỪ HYPRLAND HOẶC TERMINAL
    IpcHandler {
        target: "clock_control" // Định danh cổng IPC riêng biệt cho chiếc đồng hồ

        function open() {
            root.open()
        }

        function close() {
            root.close()
        }

        function toggle() {
            root.toggle()
        }
    }
}
