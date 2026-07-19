import QtQuick
import QtQuick.Layouts
import "../../../services"


Item {

    id: root


    property bool expanded:false


    width: expanded ? 720 : 300

    height: expanded ? 260 : 45



    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter



    clip:false



    Loader {

        id:islandLoader


        anchors.fill:parent


        active:true


        sourceComponent:

        root.expanded

        ?

        expandedComponent

        :

        compactComponent



    }






    Component {


        id:compactComponent


        Compact {}

    }





    Component {


        id:expandedComponent


        Expanded {}

    }






    Behavior on width {


        NumberAnimation {


            duration:400


            easing.type:
            Easing.OutCubic

        }


    }



    Behavior on height {


        NumberAnimation {


            duration:400


            easing.type:
            Easing.OutCubic

        }


    }






    MouseArea {


        anchors.fill:parent


        hoverEnabled:true


        acceptedButtons:
        Qt.LeftButton



        onClicked:{


            root.expanded =
            !root.expanded


        }



    }



}
