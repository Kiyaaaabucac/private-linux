import QtQuick
import QtQuick.Layouts
import "./Calendar"


Item {

    id: calendarRoot


    implicitWidth: 340
    implicitHeight: 360-380

    EventManager {

        id: eventManager

    }

    HolidayManager {
        id: holidayManager
    }

    DayDetail {

        id: dayDetail


        anchors.left: parent.right

        anchors.leftMargin: 12


        anchors.top: parent.top


        z:100


        visible: calendarRoot.detailOpen


        selectedDate:
        calendarRoot.selectedDate


        events:
        calendarRoot.selectedEvents


        holidays:
        calendarRoot.selectedHolidays

    }


    property date currentDate: new Date()

    property date selectedDate: new Date()

    property var selectedEvents: []

    property var selectedHolidays: []

    property int maxEventTitleLength: 24

    property bool detailOpen:false




    Connections {

        target: holidayManager


        function onHolidaysUpdated()
        {

            eventManager.setHolidayData(
                holidayManager.holidays
            )


            calendarRoot.updateSelectedData()

        }

    }


    Connections {

        target: eventManager


        function onEventsChanged() {

            calendarRoot.updateSelectedData()

        }

    }







    Component.onCompleted: {

        console.log("[CALENDAR] READY")

        updateSelectedData()

    }







    function updateSelectedData()
    {

        let key =
        Qt.formatDate(
            selectedDate,
            "yyyy-MM-dd"
        )


        selectedEvents =
        eventManager.getEvents(key)



        let result = []


        for(
            let i = 0;
        i < holidayManager.holidays.length;
        i++
        ){

            if(
                holidayManager.holidays[i].date === key
            ){

                result.push(
                    holidayManager.holidays[i]
                )

            }

        }


        selectedHolidays = result


        console.log(
            "[CALENDAR DATA]",
            key,
            "events:",
            selectedEvents.length,
            "holidays:",
            selectedHolidays.length
        )

    }







    function monthName(month) {


        let names = [

            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December"

        ]


        return names[month]


    }







    function daysInMonth(date) {


        return new Date(

            date.getFullYear(),

                        date.getMonth()+1,

                        0

        ).getDate()


    }







    function firstDay(date) {


        let d = new Date(

            date.getFullYear(),

                         date.getMonth(),

                         1

        )


        return d.getDay() === 0
        ? 6
        : d.getDay()-1


    }







    function dateKey(day) {


        let year =
        currentDate.getFullYear()



        let month =
        currentDate.getMonth()+1



        if(month < 10)
            month = "0" + month



            if(day < 10)
                day = "0" + day



                return year + "-" + month + "-" + day


    }







    function previousMonth() {


        currentDate =
        new Date(

            currentDate.getFullYear(),

                 currentDate.getMonth()-1,

                 1

        )


    }







    function nextMonth() {


        currentDate =
        new Date(

            currentDate.getFullYear(),

                 currentDate.getMonth()+1,

                 1

        )


    }









    Rectangle {


        anchors.fill: parent


        radius:22


        color:
        Qt.rgba(
            0,
            0,
            0,
            0.30
        )


        border.width:1


        border.color:
        Qt.rgba(
            1,
            1,
            1,
            0.12
        )







        ColumnLayout {


            anchors.fill: parent


            anchors.margins:18


            spacing:12







            // HEADER

            RowLayout {


                Layout.fillWidth:true



                Text {


                    Layout.fillWidth:true


                    text:

                    monthName(
                        calendarRoot.currentDate.getMonth()
                    )
                    +
                    " "
                    +
                    calendarRoot.currentDate.getFullYear()



                    color:"white"


                    font.pixelSize:18


                    font.bold:true


                }






                Text {


                    text:"‹"


                    color:"#ff006a"


                    font.pixelSize:28



                    MouseArea {


                        anchors.fill:parent


                        onClicked:

                        calendarRoot.previousMonth()


                    }


                }







                Text {


                    text:"›"


                    color:"#ff006a"


                    font.pixelSize:28



                    MouseArea {


                        anchors.fill:parent


                        onClicked:

                        calendarRoot.nextMonth()


                    }


                }


            }









            // WEEK HEADER


            GridLayout {


                columns:7


                Layout.fillWidth:true




                Repeater {


                    model:[

                        "Mo",
                        "Tu",
                        "We",
                        "Th",
                        "Fr",
                        "Sa",
                        "Su"

                    ]




                    delegate:Text {


                        text:modelData


                        Layout.fillWidth:true


                        horizontalAlignment:
                        Text.AlignHCenter


                        color:"#F5C2E7"


                        font.pixelSize:11


                    }


                }


            }









            // DAYS


            GridLayout {


                columns:7


                Layout.fillWidth:true


                Layout.preferredHeight:280






                Repeater {


                    model:42





                    delegate:Item {


                        Layout.fillWidth:true


                        Layout.fillHeight:true





                        property int dayNumber:

                        index -

                        calendarRoot.firstDay(

                            calendarRoot.currentDate

                        )

                        +1







                        MouseArea {


                            anchors.fill:parent



                            onClicked: {

                                if(dayNumber > 0 &&
                                    dayNumber <= calendarRoot.daysInMonth(calendarRoot.currentDate))
                                {

                                    calendarRoot.selectedDate =
                                    new Date(
                                        calendarRoot.currentDate.getFullYear(),
                                             calendarRoot.currentDate.getMonth(),
                                             dayNumber
                                    )


                                    calendarRoot.updateSelectedData()


                                    calendarRoot.detailOpen =
                                    !calendarRoot.detailOpen

                                }

                            }


                        }









                        Rectangle {


                            anchors.centerIn:parent


                            width:34


                            height:34


                            radius:17




                            color:


                            {


                                let today =
                                new Date()



                                if(

                                    dayNumber === today.getDate()

                                    &&

                                    calendarRoot.currentDate.getMonth()
                                    === today.getMonth()

                                    &&

                                    calendarRoot.currentDate.getFullYear()
                                    === today.getFullYear()

                                )

                                    return "#ff006a"



                                    return "transparent"


                            }



                        }







                        Column {


                            anchors.centerIn:parent


                            spacing:2





                            Text {


                                text:

                                dayNumber > 0

                                &&

                                dayNumber <=

                                calendarRoot.daysInMonth(

                                    calendarRoot.currentDate

                                )

                                ?

                                dayNumber

                                :

                                ""



                                color:"white"


                                font.pixelSize:13


                                horizontalAlignment:

                                Text.AlignHCenter


                            }







                            Rectangle {


                                width:4


                                height:4


                                radius:2



                                anchors.horizontalCenter:
                                parent.horizontalCenter



                                color:"#ff006a"




                                visible:


                                dayNumber > 0

                                &&

                                dayNumber <=

                                calendarRoot.daysInMonth(

                                    calendarRoot.currentDate

                                )

                                &&

                                eventManager.hasEvent(

                                    calendarRoot.dateKey(dayNumber)

                                )


                            }


                        }


                    }


                }


            }









            // TODAY EVENT CARD


            Rectangle {


                Layout.fillWidth:true


                Layout.preferredHeight:90


                radius:16



                color:

                Qt.rgba(
                    1,
                    1,
                    1,
                    0.05
                )


                border.width:1


                border.color:

                Qt.rgba(
                    1,
                    1,
                    1,
                    0.10
                )


                MouseArea {

                    anchors.fill: parent

                    propagateComposedEvents:true

                    onClicked:{
                        calendarRoot.detailOpen = false
                    }

                }




                ColumnLayout {


                    anchors.fill:parent


                    anchors.margins:12


                    spacing:6





                    Text {


                        text:

                        "Events"


                        color:"#F5C2E7"


                        font.pixelSize:12


                        font.bold:true


                    }






                    Repeater {

                        model:
                        calendarRoot.selectedEvents



                        delegate: Text {

                            Layout.fillWidth:true


                            text:
                            "●  "
                            +
                            modelData.time
                            +
                            "  "
                            +
                            (
                                modelData.title.length >
                                calendarRoot.maxEventTitleLength

                                ?

                                modelData.title.substring(
                                    0,
                                    calendarRoot.maxEventTitleLength
                                )
                                +
                                "..."

                                :

                                modelData.title
                            )



                            color:"white"


                            font.pixelSize:12


                            elide:
                            Text.ElideRight


                            maximumLineCount:1


                            clip:true

                        }

                    }







                    Text {


                        visible:

                        calendarRoot.selectedEvents.length === 0



                        text:

                        "No events"



                        color:"#A6ADC8"


                        font.pixelSize:11


                        opacity:0.5


                    }


                }


            }




        }


    }


}
