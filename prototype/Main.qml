pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import prototype

import QtCore

// Welcome to Main! This is the entrypoint to the User Interface. Our root object is a ViewerWindow.
// Highlander rules - only one Main window w/ special behaviors. There can be many child windows.


ViewerWindow {
    id: main
    main: main
    flags:  Qt.Window
    // backend property string appPath
    // backend property string backend // "py" or "cpp"

    property var childWindows: []
    property string requestOpen //backend
    property ApplicationWindow purgatory
    property string browserRequestOpen


    // APP SETTINGS -- used across windows
    // property real pixelRatio:  Screen.devicePixelRatio
    // property bool darkMode: Application.styleHints.colorScheme === Qt.ColorScheme.Dark
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

    onClosing: (close) => {

        if (childWindows.length > 0) {
            close.accepted = false
            main.show()
            // exitDialog.open()
            closeChildWindows()
            close.accepted = true
            main.close()

        }
    }

    Dialog {
        id: exitDialog
        title: `Close x windows?`
        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            closeChildWindows()

        }

        onRejected: console.log("Cancel clicked")
        modal: false
    }



    Component.onCompleted: {
        // SET DEFAULT LISTENER AT C:\Users\uSeRnAmE\output.glb
        main.filePath = (StandardPaths.writableLocation(StandardPaths.HomeLocation)+"/output.glb").slice(8)

        console.log("Welcome to ABCQ!")
    }

    Label{

        Action{
            id: shortProto
            property bool showPath: false
            shortcut: "F4"
            onTriggered: showPath = !showPath
        }

        property string substring: backend === "cpp" ? appPath+"/prototype.bat" : "🐍🐍🐍🐍🐍"
        anchors.fill: parent
        color: "green"
        z:10000
        text:  backend  + "\n" + appPath  + "\n" + substring
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: main.width/30
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

        // if (childWindows.length === 0) {
        //     main.show()
        // }

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


