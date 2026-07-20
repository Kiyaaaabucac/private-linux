pragma Singleton

import QtQml
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Biến cờ động điều khiển trạng thái ẩn/hiện của màn hình khóa
    property bool locked: false

    function open() {
        // ĐỘT PHÁ BẢO MẬT: Nếu đang khóa rồi thì NUỐT LỆNH, chặn đứng hoàn toàn việc gọi đúp 2 lần!
        if (root.locked) {
            console.log("[SERVICE DEBUG] LOCKSCREEN ALREADY OPENED - IGNORED TRIPLE CALL")
            return
        }

        root.locked = true
        console.log("[SERVICE DEBUG] LOCKSCREEN OPENED")
    }

    function close() {
        root.locked = false
        console.log("[SERVICE DEBUG] LOCKSCREEN CLOSED")
    }

    // Bộ nhận lệnh điều hướng đóng/mở trực tiếp từ phím tắt hoặc Terminal IPC
    IpcHandler {
        target: "lock"

        function open() {
            root.open()
        }

        function close() {
            root.close()
        }
    }
}
