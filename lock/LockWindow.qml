import QtQuick
import Quickshell
import Quickshell.Wayland

import "../../services"
import "./components/"



PanelWindow {


    id:root



    // =========================
    // LOCK STATE
    // =========================

    visible: LockState.locked



    screen: Quickshell.screens.length > 0
    ?
    Quickshell.screens[0]
    :
    null




    // =========================
    // FULLSCREEN
    // =========================


    anchors {

        top:true

        bottom:true

        left:true

        right:true

    }




    exclusionMode:

    ExclusionMode.Ignore




    color:"transparent"




    // =========================
    // DEBUG
    // =========================


    onVisibleChanged:
    {

        console.log(
            "LOCK WINDOW:",
            visible
        )


    }






    Connections {


        target:LockState



        function onLockedChanged()
        {

            console.log(
                "LOCK STATE CHANGED:",
                LockState.locked
            )

        }


    }







    // =========================
    // BACKGROUND
    // =========================

    LockBackground {

        anchors.fill:parent

    }



    // =========================
    // CONTENT
    // =========================

    LockContent {

        anchors.fill:parent

    }




    // =========================
    // ESC CLOSE TEST
    // =========================


    Item {

        anchors.fill:parent

        focus:true

        z:100



        Keys.onEscapePressed:
        {

            console.log(
                "ESC CLOSE LOCK"
            )


            LockState.close()

        }



        Component.onCompleted:
        {

            forceActiveFocus()

        }

    }



}
