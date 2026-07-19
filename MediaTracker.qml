pragma Singleton

import QtQml
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Io
import "."


Singleton {


    id: root


    property MprisPlayer player:null

    Component.onCompleted: {

        root.player = Players.active

        console.log(
            "MEDIA TRACKER LOADED"
        )

        root.update()

    }



    Connections {
        target: Players

        function onActiveChanged() {

            console.log("PLAYER ACTIVE CHANGED")

            root.player = Players.active

            root.update()
        }
    }

    Timer {

        id:updateDelay

        interval:500
        repeat:false

        onTriggered:{
            root.update()
        }

    }


    Connections {

        target: root.player

        ignoreUnknownSignals:true


        function onTrackTitleChanged(){

            updateDelay.restart()

        }


        function onTrackArtistChanged(){

            updateDelay.restart()

        }

    }



        function onPlaybackStateChanged(){


            if(
                root.player &&
                root.player.playbackState
                !== MprisPlaybackState.Playing
            ){

                // không clear ngay
                // để pause không mất lyric

            }

        }








    function update() {

        if (!root.player) {
            console.log("NO PLAYER")
            return
        }

        console.log(
            "UPDATE:",
            root.player.trackTitle,
            root.player.trackArtist
        )

        Lyrics.setTrack(
            root.player.trackTitle,
            root.player.trackArtist,
            root.player.trackAlbum
        )
    }
}





