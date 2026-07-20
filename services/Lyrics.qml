pragma Singleton

import QtQml
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "."

Singleton {

    id: root


    // =====================
    // STATE
    // =====================


    property string currentTrack:""

    property string currentTitle:""
    property string currentArtist:""
    property string currentAlbum:""



    property string currentLyrics:""

    property string currentLine:""
    property string currentLine1:""
    property string currentLine2:""


    property real lineProgress1:0
    property real lineProgress2:0



    property var lyricLines:[]



    property int currentIndex:0
    property int displayedIndex:0


    // =====================
    // LYRIC SPLIT CACHE
    // =====================

    property int lastSplitIndex:-1


    property int requestId:0



    // =====================
    // SOURCE STATE
    // =====================


    property string lyricsSource:""

    property bool lyricsLoading:false

    property bool hasLyrics:false



    // manual file

    property bool manualLyrics:false

    property string selectedCustomFile:""



    // custom ưu tiên

    property bool customOverride:true

    property int sourceMode:0

    property real lineProgress:0


    // =====================
    // PATH
    // =====================


    property string cachePath:

    Quickshell.env("HOME")
    +
    "/.cache/quickshell/lyrics/"



    property string customPath:

    Quickshell.env("HOME")
    +
    "/.config/quickshell/lyrics/custom/"



    property string customDatabase:

    Quickshell.env("HOME")
    +
    "/.config/quickshell/lyrics/custom.conf"


    property var customMap: ({})





    signal lyricsFound(string lyrics)


    Component.onCompleted:{
        loadCustomDatabase()
    }



    // =====================
    // CACHE READER
    // =====================


    Process {


        id:cacheReader


        property string buffer:""



        stdout:SplitParser{


            onRead:line=>{


                cacheReader.buffer +=
                line+"\n"


            }

        }





        onExited:{


            let text =
            cacheReader.buffer.trim()



            console.log(
                "CACHE SIZE:",
                text.length
            )



            if(text.length > 10)
            {


                console.log(
                    "CACHE HIT"
                )


                root.applyLyrics(
                    text,
                    "cache"
                )


            }

            else
            {


                console.log(
                    "CACHE MISS"
                )


                root.search(
                    root.currentTitle,
                    root.currentArtist
                )


            }


        }


    }







    // =====================
    // LRCLIB FETCH
    // =====================



    Process {


        id:fetcher


        property string buffer:""

        property int request:0




        stdout:SplitParser{


            onRead:line=>{


                fetcher.buffer +=
                String(line)


            }


        }






        onExited:{


            Qt.callLater(()=>{


                let result =
                fetcher.buffer.trim()



                console.log(
                    "LRCLIB SIZE:",
                    result.length
                )




                if(fetcher.request !== root.requestId)
                    return




                    if(!result)
                    {


                        console.log(
                            "LRCLIB EMPTY"
                        )


                        root.lyricsLoading=false

                        return


                    }





                    let data



                    try{


                        data =
                        JSON.parse(result)


                    }

                    catch(e){


                        console.log(
                            "JSON ERROR",
                            e
                        )


                        return


                    }






                    let lyrics =
                    data.syncedLyrics || ""





                    if(!lyrics)
                    {

                        console.log(
                            "NO SYNCED LYRICS"
                        )


                        return

                    }





                    root.applyLyrics(
                        lyrics,
                        "lrclib"
                    )



                    root.saveCache(
                        root.currentTitle,
                        root.currentArtist,
                        lyrics
                    )



            })


        }


    }


    // =====================
    // CUSTOM DATABASE
    // =====================


    function saveCustomDatabase()
    {
        let json =
        JSON.stringify(
            root.customMap,
            null,
            2
        )


        let writer =
        Qt.createQmlObject(
            `
            import Quickshell
            import Quickshell.Io

            Process{}
            `,
            root
        )


        writer.command=[
            "bash",
            "-c",
            "mkdir -p ~/.config/quickshell/lyrics && printf '%s' '" +
            json.replace(/'/g,"'\\''") +
            "' > \""+
            customDatabase+
            "\""
        ]


        writer.running=true
    }



    function saveCustomMapping(title,artist,path)
    {
        let key =
        title + "-" + artist


        let updated = Object.assign({}, root.customMap)

        updated[key] = path

        root.customMap = updated


        saveCustomDatabase()


        console.log(
            "SAVE CUSTOM MAP:",
            key,
            path
        )
    }



    function loadCustomDatabase()
    {
        let reader =
        Qt.createQmlObject(
            `
            import Quickshell
            import Quickshell.Io

            Process {

                property string data:""

                stdout:SplitParser{

                    onRead:line=>{
                        data += line
                    }

                }

            }
            `,
            root
        )


        reader.command=[
            "bash",
            "-c",
            "cat \""+
            customDatabase+
            "\" 2>/dev/null"
        ]


        reader.onExited.connect(()=>{

            try{

                if(reader.data.length>2)
                {
                    let parsed =
                    JSON.parse(reader.data)

                    if(typeof parsed === "object" && parsed !== null)
                    {
                        root.customMap = parsed

                        console.log(
                            "CUSTOM DATABASE LOADED"
                        )
                    }
                    else
                    {
                        root.customMap = ({})
                    }
                }

            }
            catch(e)
            {
                root.customMap=({})
            }

        })


        reader.running=true
    }



    // =====================
    // TRACK CHANGE
    // =====================


    function setTrack(title,artist,album)
    {


        console.log(
            "SET TRACK:",
            title,
            artist
        )



        if(!title || !artist)
            return





            let track =
            title + "-" + artist





            if(track === root.currentTrack)
                return





                let oldTrack =
                root.currentTrack

                root.currentTrack = track



                root.currentTitle = title

                root.currentArtist = artist

                root.currentAlbum = album





                // nếu đang dùng manual file
                // thì giữ nguyên lyrics


                if(oldTrack !== track)
                {
                    root.manualLyrics = false
                    root.selectedCustomFile = ""
                }

                root.currentLyrics=""

                root.currentLine=""
                root.currentLine1=""
                root.currentLine2=""

                root.lineProgress=0
                root.lineProgress1=0
                root.lineProgress2=0

                root.lyricLines=[]

                root.currentIndex=0

                root.displayedIndex=0

                root.lastSplitIndex=-1





                root.requestId++



                root.lyricsLoading=true

                root.hasLyrics=false

                root.lyricsSource=""


                if(
                    root.manualLyrics &&
                    root.selectedCustomFile !== ""
                )
                {
                    console.log(
                        "USING SAVED CUSTOM:",
                        root.selectedCustomFile
                    )

                    root.loadFile(
                        root.selectedCustomFile
                    )

                    return
                }


                let customKey =
                root.currentTitle +
                "-" +
                root.currentArtist


                if(root.customMap[customKey])
                {
                    console.log(
                        "CUSTOM MAP HIT:",
                        root.customMap[customKey]
                    )

                    root.loadFile(
                        root.customMap[customKey]
                    )

                    return
                }


                switch(root.sourceMode)
                {

                    case 1:

                        console.log("FORCE CACHE")

                        root.loadCache(
                            title,
                            artist
                        )

                        break


                    case 2:

                        console.log("FORCE CUSTOM")

                        root.loadCustom(
                            title,
                            artist
                        )

                        break


                    case 3:

                        console.log("FORCE LRCLIB")

                        root.search(
                            title,
                            artist
                        )

                        break


                    default:

                        console.log("AUTO MODE")


                        if(root.customOverride)
                        {
                            root.loadCustom(
                                title,
                                artist
                            )
                        }
                        else
                        {
                            root.loadCache(
                                title,
                                artist
                            )
                        }

                }


    }






    // =====================
    // SEARCH LRCLIB
    // =====================


    function search(title,artist)
    {


        fetcher.running=false


        fetcher.buffer=""


        fetcher.request =
        root.requestId





        fetcher.command=[


            "curl",
            "-sG",


            "--data-urlencode",
            "track_name="+title,


            "--data-urlencode",
            "artist_name="+artist,


            "https://lrclib.net/api/get"


        ]





        Qt.callLater(()=>{


            fetcher.running=true


        })


    }






    // =====================
    // NAME
    // =====================


    function sanitize(text)
    {


        return text.replace(
            /[\/\\:*?"<>|]/g,
            "_"
        )


    }





    function cacheFile(title,artist)
    {


        return cachePath
        +
        sanitize(title)
        +
        "-"
        +
        sanitize(artist)
        +
        ".lrc"


    }






    function customFile(title,artist)
    {


        return customPath
        +
        sanitize(title)
        +
        "-"
        +
        sanitize(artist)
        +
        ".lrc"


    }






    // =====================
    // LOAD CUSTOM
    // =====================


    function loadCustom(title,artist)
    {


        let file =
        customFile(
            title,
            artist
        )



        console.log(
            "CUSTOM PATH:",
            file
        )





        let reader =
        Qt.createQmlObject(
            `

            import Quickshell
            import Quickshell.Io


            Process {


                property string buffer:""



                stdout:SplitParser{


                    onRead:line=>{


                        buffer +=
                        line + "\\n"


                    }


                }


            }

            `,
            root
        )






        reader.command=[


            "bash",
            "-c",


            "cat \""+
            file+
            "\" 2>/dev/null"


        ]





        reader.onExited.connect(()=>{


            let text =
            reader.buffer.trim()





            if(text.length > 10)
            {


                console.log(
                    "CUSTOM HIT"
                )



                root.applyLyrics(
                    text,
                    "custom"
                )



            }

            else
            {


                console.log(
                    "CUSTOM MISS"
                )



                root.loadCache(
                    title,
                    artist
                )


            }



        })





        reader.running=true


    }







    // =====================
    // LOAD CACHE
    // =====================


    function loadCache(title,artist)
    {


        cacheReader.running=false


        cacheReader.buffer=""





        let file =
        cacheFile(
            title,
            artist
        )



        console.log(
            "CACHE PATH:",
            file
        )





        cacheReader.command=[


            "bash",
            "-c",


            "cat \""+
            file+
            "\" 2>/dev/null"


        ]





        cacheReader.running=true



    }






    // =====================
    // APPLY LYRICS
    // =====================


    function applyLyrics(text,source)
    {


        root.currentLyrics=text


        root.lyricsSource=source


        root.parseLyrics(text)



        root.hasLyrics =
        root.lyricLines.length > 0



        root.lyricsLoading=false



        root.lyricsFound(text)



        console.log(
            "LYRICS SOURCE:",
            source
        )


    }

    // =====================
    // SAVE CACHE
    // =====================


    function saveCache(title,artist,text)
    {


        let file =
        cacheFile(
            title,
            artist
        )



        let writer =
        Qt.createQmlObject(
            `

            import Quickshell
            import Quickshell.Io


            Process{}

            `,
            root
        )





        writer.command=[


            "bash",
            "-c",


            "mkdir -p \""+
            cachePath+
            "\" && printf '%s' \""+
            text.replace(
                /"/g,
                '\\"'
            )+
            "\" > \""+
            file+
            "\""


        ]





        writer.running=true





        console.log(
            "CACHE SAVE:",
            file
        )


    }







    // =====================
    // PARSE LRC
    // =====================


    function parseLyrics(text)
    {


        let lines=[]





        for(
            let line of text.split("\n")
        )
        {


            let match =
            line.match(
                /\[(\d+):(\d+(?:\.\d+)?)\]\s*(.*)/
            )





            if(
                match &&
                match[3].trim() !== ""
            )
            {


                lines.push({

                    time:
                    Number(match[1]) * 60
                    +
                    Number(match[2]),


                           text:
                           match[3].trim()

                })


            }


        }





        root.lyricLines =
        lines





        console.log(
            "LYRIC COUNT:",
            lines.length
        )



    }

    function splitCurrentLine()
    {


        if(root.lastSplitIndex === root.currentIndex)
            return


            root.lastSplitIndex =
            root.currentIndex



            root.currentLine1=""
            root.currentLine2=""


            let text =
            root.currentLine.trim()


            if(text==="")
                return



                let words =
                text.split(/\s+/)



                if(text.length < 28)
                {
                    root.currentLine1=text
                    root.currentLine2=""

                    return

                }




                let mid =
                Math.floor(
                    words.length/2
                )



                root.currentLine1 =
                words
                .slice(0,mid)
                .join(" ")



                root.currentLine2 =
                words
                .slice(mid)
                .join(" ")



    }









    // =====================
    // LYRIC SYNC
    // =====================


    Timer {

        interval:50

        running:true

        repeat:true


        onTriggered:{


            if(!Players.active)
                return


                if(root.lyricLines.length===0)
                    return



                    let position =
                    Players.active.position



                    let index=-1


                    for(
                        let i=0;
            i<root.lyricLines.length;
            i++
                    ){

                        if(
                            position >= root.lyricLines[i].time
                        ){

                            index=i

                        }
                        else
                        {
                            break
                        }

                    }




                    if(index>=0)
                    {

                        if(root.currentIndex !== index)
                        {
                            root.currentIndex=index
                            root.currentLine =
                            root.lyricLines[index].text
                        }



                        if(root.lastSplitIndex !== index)
                        {

                            root.splitCurrentLine()

                            root.lastSplitIndex=index

                        }



                        let start =
                        root.lyricLines[index].time


                        let end =
                        (index + 1 < root.lyricLines.length)

                        ?
                        root.lyricLines[index+1].time

                        :

                        start + 5


                        let progress =
                        Math.max(
                            0,
                            Math.min(
                                1,
                                (position-start)/(end-start)
                            )
                        )



                        root.lineProgress =
                        progress



                        // =====================
                        // SPLIT LINE PROGRESS
                        // =====================


                        if(root.currentLine2 === "")
                        {


                            // lyric chỉ có 1 dòng

                            root.lineProgress1 =
                            progress


                            root.lineProgress2 =
                            0


                        }
                        else
                        {


                            // lyric có 2 dòng

                            root.lineProgress1 =
                            Math.min(
                                1,
                                progress * 2
                            )



                            root.lineProgress2 =
                            Math.max(
                                0,
                                (progress - 0.5) * 2
                            )


                        }
                    }


        }

    }










    // =====================
    // MANUAL LOAD FILE
    // =====================


    function loadFile(path)
    {


        let reader =
        Qt.createQmlObject(
            `

            import Quickshell
            import Quickshell.Io



            Process {


                property string data:""




                stdout:SplitParser{


                    onRead:line=>{


                        data +=
                        line+"\n"


                    }


                }





                onExited:{



                    if(data.length > 10)
                    {

                        root.applyLyrics(
                            data,
                            "custom"
                        )



                        root.currentIndex=0



                        console.log(
                            "MANUAL LOAD:",
                            path
                        )


                    }



                }


            }


            `,
            root
        )






        reader.command=[

            "cat",
            path

        ]




        reader.running=true



    }








    // =====================
    // SELECT CUSTOM FILE
    // =====================

    function setCustomFile(path)
    {
        console.log("SELECT FILE:", path)

        selectedCustomFile = path

        manualLyrics = true
        sourceMode = 2
        saveCustomMapping(currentTitle,currentArtist,path)

        currentIndex = 0
        displayedIndex = 0

        currentLine = ""
        currentLine1 = ""
        currentLine2 = ""

        lineProgress = 0
        lineProgress1 = 0
        lineProgress2 = 0

        loadFile(path)
    }








    // =====================
    // CLEAR
    // =====================


    function clearTrack()
    {


        root.currentTrack=""

        root.currentTitle=""

        root.currentArtist=""

        root.currentAlbum=""



        root.currentLyrics=""

        root.currentLine=""
        root.currentLine1=""
        root.currentLine2=""

        root.lineProgress=0
        root.lineProgress1=0
        root.lineProgress2=0



        root.lyricLines=[]



        root.currentIndex=0

        root.lastSplitIndex=-1

        root.displayedIndex=0




        root.lyricsSource=""

        root.lyricsLoading=false

        root.hasLyrics=false



        root.manualLyrics=false

        root.selectedCustomFile=""



    }


}
