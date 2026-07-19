import QtQuick
import Quickshell.Io


Item {

    id: holidayManager


    // ==========================
    // CONFIG
    // ==========================

    property string countryCode: "VN"


    property var holidays: []



    signal holidaysUpdated()



    // ==========================
    // API PROCESS
    // ==========================

    Process {

        id: holidayFetcher


        stdout: StdioCollector {

            onStreamFinished: {


                try {


                    let raw = text.trim()



                    if(raw.length === 0)
                    {

                        console.log(
                            "[HOLIDAY] Empty response"
                        )

                        return

                    }



                    let data =
                    JSON.parse(raw)



                    let result = []



                    for(
                        let i = 0;
                        i < data.length;
                        i++
                    )
                    {


                        result.push({

                            "id":
                            "holiday-" + i,

                            "date":
                            data[i].date,

                            "title":
                            data[i].localName
                            ||
                            data[i].name,

                            "time":
                            "",

                            "type":
                            "holiday",

                            "description":
                            data[i].name

                        })


                    }



                    holidayManager.holidays =
                    result



                    console.log(
                        "[HOLIDAY] Loaded:",
                        result.length
                    )



                    holidaysUpdated()



                }


                catch(error)
                {


                    console.log(
                        "[HOLIDAY ERROR]",
                        error
                    )


                }


            }

        }

    }







    // ==========================
    // LOAD API
    // ==========================


    function load()
    {


        let year =
        new Date().getFullYear()



        let url =
        "https://date.nager.at/api/v3/PublicHolidays/"
        +
        year
        +
        "/"
        +
        countryCode




        console.log(
            "[HOLIDAY API]",
            url
        )



        holidayFetcher.command =
        [
            "bash",
            "-c",
            "curl -s '" + url + "'"
        ]



        holidayFetcher.running = true


    }







    // ==========================
    // QUERY
    // ==========================


    function hasHoliday(date)
    {


        for(
            let i=0;
            i<holidays.length;
            i++
        )
        {


            if(
                holidays[i].date === date
            )

                return true


        }


        return false

    }






    function getHoliday(date)
    {


        let result = []



        for(
            let i=0;
            i<holidays.length;
            i++
        )
        {


            if(
                holidays[i].date === date
            )

            {

                result.push(
                    holidays[i]
                )

            }


        }



        return result


    }






    Component.onCompleted:
    {

        console.log(
            "[HOLIDAY MANAGER READY]"
        )


        load()

    }

}
