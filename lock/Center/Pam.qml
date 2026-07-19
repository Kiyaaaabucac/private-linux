import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pam
import "../../../services"

Item {
    id: pamRoot
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: 240
    Layout.preferredHeight: 60

    property string buffer: ""
    property int pamState: 0 // 0: Normal, 1: Error

    onBufferChanged: {
        if (buffer.length > 0 && pamState === 0) {
            popAnimator.restart()
        }
    }

    PamContext {
        id: passwd
        config: "passwd"

        onResponseRequiredChanged: {
            if (!responseRequired) return
                respond(pamRoot.buffer)
                pamRoot.buffer = ""
        }

        onCompleted: res => {
            if (res === PamResult.Success) {
                console.log("PAM AUTHENTICATION SUCCESS")
                pamRoot.pamState = 0
                if (typeof LockState !== "undefined") {
                    LockState.close()
                }
            } else {
                console.log("PAM AUTHENTICATION ERROR")
                pamRoot.pamState = 1
                pamRoot.buffer = ""
                shakeAnimator.start() // KÍCH HOẠT HIỆU ỨNG RUNG LẮC KHI SAI PASS
                errorResetTimer.restart()
            }
        }
    }

    function handleKeyInput(event) {
        if (pamState === 1) pamState = 0

            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (buffer.length > 0 && !passwd.active) {
                    passwd.start()
                }
                return
            }

            if (event.key === Qt.Key_Backspace) {
                if (event.modifiers & Qt.ControlModifier) {
                    buffer = ""
                } else {
                    buffer = buffer.slice(0, -1)
                }
                return
            }

            if (event.text && event.text.length === 1) {
                let charCode = event.text.charCodeAt(0)
                if (charCode >= 32 && charCode !== 127) {
                    buffer += event.text
                }
            }
    }

    Timer {
        id: errorResetTimer
        interval: 3000
        onTriggered: pamRoot.pamState = 0
    }

    // =========================================================================
    // KHỐI ĐỊNH NGHĨA ANIMATION CHUẨN XÁC CÚ PHÁP QML
    // =========================================================================

    // 1. Hiệu ứng rung lắc (ĐÃ SỬA: Đưa định danh property vào từng nút thắt NumberAnimation)
    SequentialAnimation {
        id: shakeAnimator
        loops: 1

        NumberAnimation { target: inputContainer; property: "anchors.horizontalCenterOffset"; to:  12; duration: 40; easing.type: Easing.OutQuad }
        NumberAnimation { target: inputContainer; property: "anchors.horizontalCenterOffset"; to: -12; duration: 70; easing.type: Easing.InOutQuad }
        NumberAnimation { target: inputContainer; property: "anchors.horizontalCenterOffset"; to:   8; duration: 70; easing.type: Easing.InOutQuad }
        NumberAnimation { target: inputContainer; property: "anchors.horizontalCenterOffset"; to:  -8; duration: 70; easing.type: Easing.InOutQuad }
        NumberAnimation { target: inputContainer; property: "anchors.horizontalCenterOffset"; to:   4; duration: 70; easing.type: Easing.InOutQuad }
        NumberAnimation { target: inputContainer; property: "anchors.horizontalCenterOffset"; to:   0; duration: 40; easing.type: Easing.InQuad }
    }

    // 2. Hiệu ứng đập nảy dấu chấm tròn khi gõ phím (ĐÃ SỬA CÚ PHÁP)
    SequentialAnimation {
        id: popAnimator

        NumberAnimation { target: dotsText; property: "scale"; to: 1.15; duration: 40; easing.type: Easing.OutQuad }
        NumberAnimation { target: dotsText; property: "scale"; to: 1.0;  duration: 100; easing.type: Easing.InQuad }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            id: statusLabel
            Layout.alignment: Qt.AlignHCenter
            text: pamRoot.pamState === 1 ? "AUTHENTICATION FAILED" : (buffer.length > 0 ? "Typing..." : "Enter your password")
            color: pamRoot.pamState === 1 ? "#ff006a" : "#A6ADC8"
            font.pixelSize: 11
            opacity: 0.6
            font.family: "JetBrains Mono"

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Rectangle {
            id: inputContainer
            Layout.preferredWidth: 240
            Layout.preferredHeight: 34
            Layout.alignment: Qt.AlignHCenter
            color: Qt.rgba(1, 1, 1, 0.04)
            radius: 6
            border.width: 1
            border.color: pamRoot.pamState === 1 ? "#ff006a" : Qt.rgba(1, 1, 1, 0.08)

            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
                id: dotsText
                anchors.centerIn: parent
                text: "•".repeat(pamRoot.buffer.length)
                color: "white"
                font.pixelSize: 16
                font.bold: true
                font.letterSpacing: 3
                transformOrigin: Item.Center
            }
        }
    }

    Component.onCompleted: {
        if (!passwd.active) {
            passwd.start()
        }
    }
}
