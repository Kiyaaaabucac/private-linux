import QtQuick
import QtQuick.Layouts
import "./Center"


Item {

    id: centerRoot


    implicitWidth: 300
    implicitHeight: 500


    function findChildPam() {
        return pamInput
    }


    ColumnLayout {

        anchors.centerIn:parent


        spacing:24



        Clock {

            Layout.alignment:
            Qt.AlignHCenter

        }



        Avatar {

            Layout.alignment:
            Qt.AlignHCenter

        }



        Pam {
            id: pamInput

            Layout.alignment: Qt.AlignHCenter

            focus: true
        }
    }
}
