import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent

    // Wallpaper
    Image {
        id: wallpaper

        anchors.fill: parent

        source: "file:///home/alone/Pictures/wallpapers/mumei.png"

        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        cache: true
    }

    // Blur
    FastBlur {
        anchors.fill: wallpaper
        source: wallpaper
        radius: 48
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: "#66000000"
    }

    // Bottom gradient
    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#00000000"
            }

            GradientStop {
                position: 0.55
                color: "#22000000"
            }

            GradientStop {
                position: 1.0
                color: "#AA000000"
            }
        }
    }

    // Vignette
    RadialGradient {
        anchors.fill: parent

        horizontalOffset: width / 2
        verticalOffset: height / 2

        horizontalRadius: width * 0.75
        verticalRadius: height * 0.75

        gradient: Gradient {
            GradientStop {
                position: 0.55
                color: "#00000000"
            }

            GradientStop {
                position: 1.0
                color: "#99000000"
            }
        }
    }

    // Fade in
    opacity: 0

    SequentialAnimation on opacity {
        running: true

        NumberAnimation {
            from: 0
            to: 1
            duration: 350
            easing.type: Easing.OutCubic
        }
    }
}
