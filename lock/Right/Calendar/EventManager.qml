import Quickshell
import QtQuick
import Quickshell.Io


Item {

    id: manager


    // ================================
    // DATABASE
    // ================================

    property var events: []

    property var holidays: []



    // ================================
    // FILE
    // ================================

    FileView {

        id: eventFile


        path:
        Qt.resolvedUrl("events.json")


        watchChanges: true



        onTextChanged: {

            console.log("[EVENT FILE CHANGED]")

            manager.load()

        }

    }





    // ================================
    // LOAD PERSONAL EVENTS
    // ================================

    function load() {

        try {

            let raw = ""


            if(typeof eventFile.text === "function") {

                raw = eventFile.text()

            }
            else {

                raw = eventFile.text

            }


            console.log(
                "[EVENT RAW]",
                raw
            )


            if(!raw || raw.length === 0) {

                console.log("[EVENT] Empty database")

                events = []

                return

            }



            let data = JSON.parse(raw)



            if(Array.isArray(data)) {

                events = data


                console.log(
                    "[EVENT] Loaded:",
                    events.length,
                    "events"
                )

            }


        }

        catch(error) {

            console.log(
                "[EVENT ERROR]",
                error
            )


            events = []

        }

    }







    // ================================
    // SAVE
    // ================================

    function save()
    {


        try {


            eventFile.write(

                JSON.stringify(
                    manager.events,
                    null,
                    4
                )

            )



            console.log(
                "[EVENT] Database saved"
            )


        }


        catch(error)
        {


            console.log(
                "[EVENT ERROR SAVE]",
                error
            )


        }


    }








    // ================================
    // HOLIDAY CONNECT
    // ================================

    function setHolidayData(data)
    {


        if(!data)
            return



            holidays =
            data



            console.log(
                "[EVENT] Holidays merged:",
                holidays.length
            )


    }







    // ================================
    // RETURN ALL EVENTS
    // ================================

    function allEvents()
    {


        return events.concat(
            holidays
        )


    }







    // ================================
    // CHECK DATE
    // ================================

    function hasEvent(date)
    {


        let list =
        allEvents()



        for(
            let i = 0;
        i < list.length;
        i++
        )
        {


            if(
                list[i].date === date
            )

                return true


        }



        return false


    }







    // ================================
    // GET EVENTS BY DATE
    // ================================

    function getEvents(date)
    {


        let result = []



        let list =
        allEvents()



        for(
            let i = 0;
        i < list.length;
        i++
        )
        {


            if(
                list[i].date === date
            )
            {


                result.push(
                    list[i]
                )


            }


        }



        return result


    }







    // ================================
    // ADD EVENT
    // ================================

    function addEvent(event)
    {


        let temp =
        events.slice()



        event.id =
        Date.now()



        temp.push(event)



        events =
        temp



        save()



        console.log(
            "[EVENT] Added:",
            event.title
        )


    }







    // ================================
    // REMOVE EVENT
    // ================================

    function removeEvent(id)
    {


        let temp =
        events.slice()



        for(
            let i=0;
        i<temp.length;
        i++
        )
        {


            if(
                temp[i].id === id
            )
            {


                temp.splice(i,1)

                break

            }


        }



        events =
        temp



        save()


    }







    // ================================
    // UPDATE EVENT
    // ================================

    function updateEvent(id,newData)
    {


        let temp =
        events.slice()



        for(
            let i=0;
        i<temp.length;
        i++
        )
        {


            if(
                temp[i].id === id
            )
            {


                newData.id =
                id



                temp[i] =
                newData



                break

            }


        }



        events =
        temp



        save()


    }







    Component.onCompleted:
    {


        console.log(
            "[EVENT MANAGER READY]"
        )


        console.log(
            "[EVENT PATH]",
            eventFile.path
        )


    }


}
