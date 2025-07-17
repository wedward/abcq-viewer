pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import "."
import Themes

import QtCore


// Welcome to Main! This is the entrypoint to the User Interface. Our root object is a ViewerWindow.
// Highlander rules - only one Main window w/ special behaviors. There can be many child windows.


ViewerWindow {
    id: main
    main: main
    // flags:  Qt.Window
    flags:  Qt.FramelessWindowHint | Qt.Window
    // backend property string appPath //
    // backend property string backend //
    // backend property obj build123d  //

    Settings {
        // property alias x: main.x
        // property alias y: main.y
        property alias userScale: main.userScale
        property alias intervalMS: main.intervalMS
        property alias theme: main.theme
    }


    Connections {
        target: build123d

        function onReplOutput(output) {
           console.log('[BUILD]: '+ output)
        }

        function onReplError(error) {
            console.log("[BUILD] err: " + error)
        }

        function onReplClosed() {
            console.log("[BUILD]: 'goodbye world!'")
        }
    }

    property string theme: Theme.themeName


    property var childWindows: []
    property string requestOpen //backend
    property ApplicationWindow purgatory
    property string browserRequestOpen


    // APP SETTINGS -- used across windows
    // property real pixelRatio:  Screen.devicePixelRatio
    property bool darkmode: Application.styleHints.colorScheme === Qt.ColorScheme.Dark
    onDarkmodeChanged: {
        if (Theme.themeName === "Auto")
            Theme.loadTheme("Auto")
    }


    property int intervalMS: 50
    readonly property int defaultIntervalMS: 50
    function resetIntervalMS () {intervalMS = defaultIntervalMS}

    // reflects users intent for UI/Text scale
    property real userScale: 1.0
    property real effectiveScale: Math.min ( 3, Math.max( 0.5 , Math.floor( userScale * 20 ) / 20 ) )
    readonly property real defaultUserScale: 1.0

    function resetScale () {userScale = defaultUserScale}
    function increaseScale(amt= 0.05, min=0.5, max=3) {
        userScale = Math.max( min, Math.min( max, userScale + amt ) )
    }
    function decreaseScale(amt=-0.05, min=0.5, max=3) {
        userScale = Math.max( min, Math.min( max, userScale + amt ) )
    }

    property real fontL: 14.0 * effectiveScale
    property real fontM: 12.0 * effectiveScale
    property real heightL: 35.0 * effectiveScale
    property real heightM: 21.0 * effectiveScale




    Component.onCompleted: {
        // SET DEFAULT LISTENER AT C:\Users\uSeRnAmE\output.glb

        // console.log(main.theme)

        if (main.theme === null) Theme.loadTheme("Auto")
        else Theme.loadTheme(main.theme)
        main.filePath = (StandardPaths.writableLocation(StandardPaths.HomeLocation)+"/output.glb").slice(8)

        console.log("FRONTEND LOADED")
        console.log('LOADING BUILD123D')
        build123d.startRepl()
    }


    Label{

        Action{
            id: shortProto
            property bool showPath: false
            shortcut: "F4"
            onTriggered: showPath = !showPath
        }


        anchors.fill: parent
        color: "green"
        z:10000
        text:  frontend  + "\n" + appPath  + "\n" 
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize:20
        visible: shortProto.showPath
    }



    function closeChildWindows() {
        var c
        for (var i = childWindows.length; i > 0; i--){
            c = childWindows.pop(i)
            c.close()
        }
    }

    onRequestOpenChanged: {
        // Handle requests to open file from c++ backend
        main.filePath = main.requestOpen
        closeDrawer()
    }

    // All new windows are created by Main and stored in childWindows
    function newWindow(){
        var vw = winLauncher.createObject()
        childWindows.push(vw)
        vw.show()
    }

    function reopen(){

        purgatory.show()
        childWindows.push(purgatory)
        purgatory = null

    }

    function browserOpen(path){
        browserRequestOpen = path
        var vw = browserWinLauncher.createObject()
        childWindows.push(vw)
        vw.show()
        browserRequestOpen = null


    }

    function abcqClose(win){
        if (purgatory != null){
            purgatory.destroy()
        }

        for (var i = 0; i < childWindows.length; i++){

            if(childWindows[i]===win){
                purgatory = childWindows.pop(i)
                purgatory.close()
            }
        }


    }

    Component {
        id: winLauncher

        ViewerWindow{
            // no bind
            filePath: {filePath = main.filePath}
            main: main
            flags: Qt.Window |  Qt.FramelessWindowHint  | Qt.WindowStaysOnTopHint
            opac: 0.1
        }
    }

    Component {
        id: browserWinLauncher

        ViewerWindow{
            // no bind
            filePath: {filePath = main.browserRequestOpen}
            main: main
            flags: Qt.Window |  Qt.FramelessWindowHint  | Qt.WindowStaysOnTopHint
            opac: 0.1
        }
    }

    // TODO: confirm exit if childWindows > 0
    // TODO: init - check if already running, show_running(), exit, like MS task mgr

}


