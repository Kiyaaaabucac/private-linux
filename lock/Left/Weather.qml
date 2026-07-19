import QtQuick
import QtQuick.Layouts
import Quickshell.Io


Item {

    id: weatherRoot


    implicitWidth: 340
    implicitHeight: 150


    property string temperature: "--°C"
    property string feelsLike: "--°C"
    property string humidity: "--%"
    property string wind: "-- km/h"
    property string condition: "Loading..."
    property string weatherSymbol: "☁"



    Process {

        id: weatherFetcher


        command: [
            "bash",
            "-c",
            "curl -s 'wttr.in/?format=j1'"
        ]


        running: true


        stdout: StdioCollector {


            onStreamFinished: {


                try {


                    let data = JSON.parse(text)


                    let current =
                    data.current_condition[0]



                    weatherRoot.temperature =
                    current.temp_C + "°C"



                    weatherRoot.feelsLike =
                    current.FeelsLikeC + "°C"



                    weatherRoot.humidity =
                    current.humidity + "%"



                    weatherRoot.wind =
                    current.windspeedKmph + " km/h"



                    weatherRoot.condition =
                    current.weatherDesc[0].value



                    let lower =
                    weatherRoot.condition.toLowerCase()



                    if(
                        lower.includes("sun") ||
                        lower.includes("clear")
                    )
                        weatherRoot.weatherSymbol="☀️"


                        else if(
                            lower.includes("rain") ||
                            lower.includes("drizzle")
                        )
                            weatherRoot.weatherSymbol="🌧️"


                            else if(
                                lower.includes("thunder")
                            )
                                weatherRoot.weatherSymbol="⛈️"


                                else if(
                                    lower.includes("snow")
                                )
                                    weatherRoot.weatherSymbol="❄️"


                                    else
                                        weatherRoot.weatherSymbol="☁"



                }

                catch(e){

                    console.log(
                        "[WEATHER ERROR]",
                        e
                    )

                }
            }
        }
    }



    Timer {

        interval: 900000

        repeat:true

        running:true


        onTriggered: {

            weatherFetcher.running=false

            weatherFetcher.running=true
        }
    }





    Rectangle {


        anchors.fill:parent


        radius:22


        color:
        Qt.rgba(0,0,0,0.30)



        border.width:1


        border.color:
        Qt.rgba(1,1,1,0.12)





        ColumnLayout {


            anchors.fill:parent


            anchors.margins:16


            spacing:6






            // HEADER

            RowLayout {


                Layout.fillWidth:true



                Text {

                    text:"Weather"

                    color:"#F5C2E7"

                    font.pixelSize:13

                    font.bold:true
                }



                Item {
                    Layout.fillWidth:true
                }



                Text {

                    text:
                    weatherRoot.temperature


                    color:"white"

                    font.pixelSize:14

                    font.bold:true
                }
            }







            // MAIN WEATHER

            RowLayout {


                Layout.fillWidth:true


                spacing:12



                Text {
                    text: weatherRoot.weatherSymbol

                    font.pixelSize: 36

                    font.family: "Noto Color Emoji"
                }



                ColumnLayout {


                    spacing:2



                    Text {

                        text:
                        weatherRoot.condition


                        color:"white"


                        font.pixelSize:13

                        font.bold:true


                        elide:
                        Text.ElideRight
                    }



                    Text {


                        text:
                        "Feels like " +
                        weatherRoot.feelsLike


                        color:"#C3BAC6"


                        font.pixelSize:11
                    }
                }
            }







            // DETAILS

            RowLayout {


                Layout.fillWidth:true


                spacing:18



                Text {

                    text:
                    "💧 " +
                    weatherRoot.humidity


                    color:"#A6ADC8"


                    font.pixelSize:10
                }



                Text {

                    text:
                    "🌬 " +
                    weatherRoot.wind


                    color:"#A6ADC8"


                    font.pixelSize:13
                }
            }

        }

    }

}
