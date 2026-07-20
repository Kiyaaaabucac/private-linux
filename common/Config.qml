pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root
    
    property QtObject options: QtObject {
        property QtObject overview: QtObject {
            property int rows: 2
            property int columns: 5
            property real scale: 0.17
            property bool enable: true
        }
        
        property QtObject hacks: QtObject {
            property int arbitraryRaceConditionDelay: 150
        }
    }

    Component.onCompleted: {
        console.log("========== CONFIG ==========")
        console.log("Rows:", options.overview.rows)
        console.log("Columns:", options.overview.columns)
        console.log("Scale:", options.overview.scale)
    }
}
