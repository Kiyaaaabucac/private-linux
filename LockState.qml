pragma Singleton

import QtQml
import QtQuick
import Quickshell
import Quickshell.Io


Singleton {

    id:root


    property bool locked:false



    function open()
    {
        locked=true

        console.log("LOCK OPEN")
    }



    function close()
    {
        locked=false

        console.log("LOCK CLOSE")
    }



    IpcHandler {

        target:"lock"


        function open()
        {
            root.open()
        }


        function close()
        {
            root.close()
        }


    }


}
