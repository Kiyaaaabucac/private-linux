import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "../../common"
import "../../services"
import "./components/" // ÉP QUÉ TẬN GỐC: Nạp toàn bộ các file nằm trong thư mục components

Scope {
    id: lockWindowScope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData

            visible: LockState.locked
            color: "transparent"

            WlrLayershell.namespace: "lockscreen"
            WlrLayershell.layer: WlrLayer.Overlay

            WlrLayershell.exclusiveZone: -1
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            onVisibleChanged: {
                console.log("[LOCK WINDOW] Screen: " + (screen ? screen.name : "N/A") + " | Seen: " + visible)
                if (visible) {
                    keyboardBridge.forceActiveFocus()
                }
            }

            Connections {
                target: LockState
                ignoreUnknownSignals: true
                function onLockedChanged() {
                    root.visible = LockState.locked
                    if (root.visible) {
                        keyboardBridge.forceActiveFocus()
                    }
                }
            }

            // Gọi trực tiếp, Quickshell tự động bốc file từ thư mục components/ đã import ở dòng 13
            LockBackground {
                anchors.fill: parent
                z: -1
            }

            LockContent {
                id: lockContent
                anchors.fill: parent
                z: 1
            }

            Item {
                id: keyboardBridge
                anchors.fill: parent
                focus: true

                Keys.onPressed: (event) => {
                    if (typeof lockContent.findChildPam === "function") {
                        let pamWidget = lockContent.findChildPam()
                        if (pamWidget) {
                            pamWidget.handleKeyInput(event)
                        }
                    }
                }
            }
        }
    }
}
