import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "../../common"
import "../../services"
import "."

Scope {
    id: dashboardScope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData

            screen: modelData

            readonly property HyprlandMonitor monitor:
            Hyprland.monitorFor(screen)

            readonly property bool monitorIsFocused:
            Hyprland.focusedMonitor?.id === monitor?.id

            visible: GlobalStates.dashboardOpen
            color: "transparent"

            WlrLayershell.namespace: "quickshell:dashboard"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            mask: Region {
                item: keyHandler
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                property bool canBeActive: root.monitorIsFocused
                active: false

                onCleared: {
                    if (!active) {
                        GlobalStates.dashboardOpen = false
                    }
                }
            }

            Connections {
                target: GlobalStates
                function onDashboardOpenChanged() {
                    if (GlobalStates.dashboardOpen) {
                        delayedGrab.start()
                    } else {
                        grab.active = false
                    }
                }
            }

            Timer {
                id: delayedGrab
                interval: Config.options.hacks.arbitraryRaceConditionDelay
                repeat: false
                onTriggered: {
                    if (grab.canBeActive) {
                        grab.active = GlobalStates.dashboardOpen
                    }
                }
            }

            Item {
                id: keyHandler
                anchors.fill: parent
                visible: GlobalStates.dashboardOpen
                focus: GlobalStates.dashboardOpen

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Return) {
                        GlobalStates.dashboardOpen = false
                        event.accepted = true
                    }
                }
            }

            Loader {
                id: dashboardLoader
                anchors.fill: parent
                active: GlobalStates.dashboardOpen

                scale: GlobalStates.dashboardOpen ? 1.0 : 0.96
                opacity: GlobalStates.dashboardOpen ? 1 : 0

                Behavior on scale {
                    NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                }

                sourceComponent: Component {
                    DashboardWidget {
                        panelWindow: root
                        screenState: root.modelData
                        nonAnimWidth: 780
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: {
                    GlobalStates.dashboardOpen = false
                }
            }
        }
    }

    IpcHandler {
        target: "dashboard"
        function toggle() { GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen }
        function open() { GlobalStates.dashboardOpen = true }
        function close() { GlobalStates.dashboardOpen = false }
    }
}
