// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import QtQuick3D

import RWatcher
// import FModel
import "."
import Themes


// import CustomComponents  //renderWatcher

pragma ComponentBehavior: Bound



ApplicationWindow {
    id: root

    // backend property string backend: "cpp" OR "py"
    // backend property string appPath

    property ApplicationWindow main: null
    property bool isMain: main===root

    property real heightUIx: main.heightL
    property real fontUIx: main.fontL

    property string filePath

    property real opac: 1.0
    property bool transparentBG: opac < 1 && !isMain

    property bool drawerShut: drawer.width === sidebar.width
    property bool drawerAjar: drawer.width - sidebar.width < 50

    property bool resizing:  screen.resizing || winResizing
    property bool winResizing: false
    property alias canUpdateScreen: updateTimer.canUpdate

    readonly property bool listening: filewatcher.listening

    function increaseOpac(amt=0.01, min=0, max=1){
        opac = Math.min(max, Math.max(min, opac+amt))
    }
    function resetOpac() {opac=1.0}



    Timer{
        id: reloadTimer
        repeat: false
        interval: 16

        triggeredOnStart: true

        property string backup

        onTriggered: {
            if (running){
                backup = root.filePath
                root.filePath = ""
            } else {
                root.filePath = backup
                backup = null
            }
        }


    }


    Item{
        id: updateTimer
        property bool canUpdate: true
        property int rcount: 0

        Timer{

            interval: 1000
            repeat: true
            running: root.resizing


            onTriggered: {

                updateTimer.canUpdate = true
                resetTimer.running = true
            }

            onRunningChanged: {
                if(!running){
                    updateTimer.canUpdate = true
                }
                else{
                    updateTimer.canUpdate = false
                }
            }

        }

        Timer{
            id: resetTimer
            interval: 16
            running: false
            repeat: false

            onTriggered: updateTimer.canUpdate = false
        }
    }

    onTransparentBGChanged: {

        if (opac < 1 ){
            root.flags = Qt.Window |  Qt.WA_TranslucentBackground |  Qt.FramelessWindowHint  | Qt.WindowStaysOnTopHint
            console.log('ghost')
        }
        else {
            root.flags = Qt.Window |  Qt.FramelessWindowHint  | Qt.WindowStaysOnTopHint
            console.log('boo')
        }
    }


    // TODO: create command line flag for screen
    width: 640  // Screen.desktopAvailableWidth/2
    height: 480  //Screen.desktopAvailableHeight/2
    visible: true
    title: "ABCQ Viewer"
    property bool viewMenus: true
    property var childWindows: []

    minimumWidth: 200
    minimumHeight: 200


    // setting the color to transparent at runtime causes issues, so we create a solid bg w/ a rect
    color:  "transparent"
    background: Rectangle{
        color: "black"
        anchors.fill: parent
        visible: !transparentBG
    }

    function toggleWatcher(){

        filewatcher.listening = !filewatcher.listening
    }

    function toggleMenus(){

        viewMenus = !viewMenus

        if (drawerAjar && !viewMenus) {
            drawer.SplitView.preferredWidth=0
        }
    }

    function toggleDrawer(){
        if (drawerAjar) openDrawer()
        else closeDrawer()
    }
    function openDrawer() {
        drawer.SplitView.preferredWidth = 220 + (heightUIx*2) + sidebar.width
    }
    function closeDrawer() {
        drawer.SplitView.preferredWidth = 0
    }

    RenderWatcher{
        id: filewatcher
        property string backup

        interval: main.intervalMS

        watchPath: filePath

        // UNLOAD ASSET
        onReloadTriggered: {
            backup = root.filePath
            root.filePath = ""
            counting = true
        }

        // RELOAD FROM DISK
        onReloadComplete: {
            root.filePath = backup
            backup = ""
        }
    }


    menuBar: MyMenuBar {
        id: mb
        win: root
        // infoText: "TopBarText"
        visible: root.viewMenus

        property string spacer: ":      \t"
        font.pixelSize: fontUIx

        MyMenu {
            id: fileMenu
            fontUIx: root.fontUIx
            title: "File"

            Action {
             

                text: "New Window"
                onTriggered: newWindow()
                shortcut: StandardKey.New

            }

            Action{

                text: "Refresh"
                onTriggered: reloadTimer.start()
                shortcut: "F5"

            }
            Action{
                property string substring: viewMenus ? "Hide":"Show"
                text: substring + " Menus" 
                onTriggered: toggleMenus()
                shortcut: "Escape"
            }
            Action{
                property string substring: drawerAjar ? "Show":"Hide"
                text: substring + " Drawer"  
                onTriggered: toggleDrawer()
                shortcut: "Tab"

            }

            Action{

                text: "Increase Text Size"   
                onTriggered: main.increaseScale()
                shortcut: "="

            }
            Action{
                text: "Decrease Text Size"   
                onTriggered: main.decreaseScale()
                shortcut: "-"

            }
            Action{
                text: "Reset Text Size"   
                onTriggered: main.resetScale()
                shortcut: "Backspace"

            }

            Action{
                property string substring: filewatcher.listening ? "ON" : "OFF"
                text: "Auto-Reload: " + substring  
                onTriggered: toggleWatcher()
                shortcut: "F2"

            }
            Action{
                text: "Reset Reload Interval"  
                onTriggered: main.resetIntervalMS()
                // shortcut: "Ctrl+F2"

            }


            Action{
                text: "Launch Prototype Sandbox"  
                onTriggered: Qt.openUrlExternally(appPath+"/proto.bat")
                shortcut: "F6"
            }


            Action {
                text: "Exit"
                onTriggered: Qt.exit(0)
                shortcut: StandardKey.Quit
            }


        }
        MyMenu {
            id: cameraMenu
            fontUIx: root.fontUIx
            title: "Camera"

            Action{
                text: "Top"
                onTriggered: viewer.scn.top()

                shortcut: "1"
            }
            Action{
                text: "Bottom"
                onTriggered: viewer.scn.bottom()
                shortcut: "2"
            }
            Action{
                text: "Right"
                onTriggered: viewer.scn.right()

                shortcut: "3"
            }
            Action{
                text: "Left"
                onTriggered: viewer.scn.left()

                shortcut: "4"
            }
            Action{
                text: "Front"
                onTriggered: viewer.scn.front()
 
                shortcut: "5"
            }
            Action{
                text: "Back"
                onTriggered: viewer.scn.back()
 
                shortcut: "6"
            }
            Action{
                property string substring: viewer.scn.activeCam === viewer.scn.camOrtho ? "Orthographic":"Perspective"
                text: "View: " + substring 
                onTriggered: viewer.scn.swapCam()
  
                shortcut: "7"
            }
            Action{
                property string substring: viewer.scn.normsOn ? "Normals":"OFF"
                text: "Debug: " + substring 
                onTriggered: viewer.scn.toggleNorms()
 
                shortcut: "8"
            }
            Action{
                property string substring: viewer.scn.shadowQual ===Light.Hard ? "Hard":"Soft"
                text: "Shadows: " + substring 
                onTriggered: viewer.scn.toggleShadowQual()
 
                shortcut: "9"
            }
            Action{
                // property string substring: viewer.scn.shadowQual ===Light.Hard ? "Hard":"Soft"
                text: "Reset Zoom"
                onTriggered: viewer.scn.resetZoom()
 
                shortcut: "0"
            }
            Action{
                text: "Resest Z-dist."
                onTriggered: viewer.scn.resetZDist()
 
                shortcut: "Ctrl+0"
            }
        }
        MyMenu {
            fontUIx: root.fontUIx
            title: "Animation"

            Action{
                property string substring: viewer.scn.animRunning ? "Stop":"Start"
                text: "Animation: " + substring
                onTriggered: viewer.scn.toggleAnim()
 
                shortcut: "Space"
            }
            Action{
                text: "Increase Speed"
                onTriggered: viewer.scn.increaseAnimSpeed(-0.1)
 
                shortcut: "."
            }
            Action{
                text: "Decrease Speed"
                onTriggered: viewer.scn.increaseAnimSpeed(.1)
 
                shortcut: ","
            }
            Action{
                text: "Toggle Direction"
                onTriggered: viewer.scn.changeAnimDir()
 
                shortcut: "m"
            }
            Action{
                text: "Toggle Axis"
                onTriggered: viewer.scn.changeAnimAxis()
 
                shortcut: "n"
            }
        }
        // MyMenu {
        //     fontUIx: root.fontUIx
        //     title: backend ==="cpp" ? "Python" : "🐍 🐍 🐍"
        //     Action {
        //         property string substring: backend === "cpp" ?"Launch prototype.py" : "🐍 🐍 🐍 🐍 🐍"
        //         // property bool cpp: typeof appPath !== "undefined"
        //         text: "<table width='100%'><tr>" +
        //               "<td align='center'>" + "🐍 "+ substring +" 🐍" + "</td>" +
        //               "</tr></table>"
        //         onTriggered: Qt.openUrlExternally(appPath+"/prototype.bat")
        //         shortcut: "Ctrl+Shift+F3"

        //         // check if running cpp/py
        //         enabled: backend === "cpp"
        //     }
        // }

        MyMenu {
            fontUIx: root.fontUIx
            title: "Theme"

            Action{
                property string substring: Theme.themeName === "Auto" ? "✅ " : ""
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Automatic" + "</td>" +
                      "<td align='right'>" + substring + "</td>" +
                      "</tr></table>"
                onTriggered: Theme.loadTheme("Auto")

            }
            Action{
                property string substring: Theme.themeName === "Light" ? "✅ " : ""
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Light" + "</td>" +
                      "<td align='right'>" + substring + "</td>" +
                      "</tr></table>"
                onTriggered: Theme.loadTheme("Light")

            }
            Action{
                property string substring: Theme.themeName === "Dark" ? "✅ " : ""
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Dark" + "</td>" +
                      "<td align='right'>" + substring + "</td>" +
                      "</tr></table>"
                onTriggered: Theme.loadTheme("Dark")

            }
            Action{
                property string substring: Theme.themeName === "Wedward" ? "✅ " : ""
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Wedward" + "</td>" +
                      "<td align='right'>" + substring + "</td>" +
                      "</tr></table>"
                onTriggered: Theme.loadTheme("Wedward")


            }
        }

    }

    SplitView{
        id: screen
        z: 0
        visible: true
        anchors.fill: parent
        spacing: 0

        handle:
            Rectangle {
                implicitWidth: 10
                color: "firebrick"
                border.color: "firebrick"
                opacity: 1
            }

        RowLayout {
            id: drawer
            anchors.left: parent.left
            spacing: 0
            SplitView.minimumWidth: root.viewMenus ? sidebar.width : 0

            //tray
            Sidebar {
                id: sidebar
                visible: true //root.viewMenus
                win: root
                Layout.minimumWidth: root.viewMenus ? heightUIx : Math.min(drawer.width,heightUIx)
                Layout.maximumWidth: root.viewMenus ? heightUIx : drawer.width
                Layout.fillHeight: true

                onClicked: {
                    // call later to avoid opening before StackLayout updates
                    Qt.callLater(openDrawer)
                }
                onClickedAgain: {
                    toggleDrawer()
                }

                // onCurrentTabIndexChanged: Qt.callLater(openDrawer)


            }
            Rectangle {

                color: Theme.theme.surface1

                Layout.fillHeight: true
                Layout.fillWidth: true

                StackLayout {
                    id: stack

                    anchors.fill: parent
                    currentIndex: sidebar.currentTabIndex

                    FileSystemView {
                        id: fileSystemView
                        color: Theme.theme.surface1
                        onFileClicked: path =>

                                        {
                                           if (path.slice(-4)==='brep'){

                                               console.log('BREP!!! ' + path)
                                               build123d.sendCommand('BREP '+path)
                                               root.filePath = appPath + "/output.glb"

                                            }
                                           else {
                                                root.filePath = path
                                           }

                                       }

                        fontUIx: root.fontUIx

                        onRequestOpen: path => {
                            root.main.browserOpen(path)


                        }
                        opacity: !drawerAjar ? 1 : (drawer.width-sidebar.width)/50
                    }

                    Controls{
                        id: ctrl
                        scn: viewer.scn
                        win: root
                        SplitView.fillHeight: true
                        // SplitView.fillWidth: true
                        SplitView.preferredWidth: 250
                        layer.enabled: false
                        layer.live: root.canUpdateScreen
                        visible: !root.drawerShut && sidebar.currentTabIndex === 1
                        opacity: !drawerAjar ? 1 : (drawer.width-sidebar.width)/50
                    }

                    Environment{
                        color: "blue"
                        SplitView.fillHeight: true
                        SplitView.preferredWidth: 250
                    }


                }
            }
        }


        Viewer{
            // visible: false
            id: viewer
            filePath: root.filePath
            win: root
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            // disable 3d updates when resizing the drawer/window
            layer.enabled: true
            layer.live: root.canUpdateScreen
            layer.smooth: true
            layer.mipmap: true


        }
    }


    ResizeButton{
        z: 10
        text:"↘️"
        font.pixelSize: fontUIx *2
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onPressed: {
            root.startSystemResize(Qt.BottomEdge | Qt.RightEdge)
            root.winResizing = true
        }
        onReleased: root.winResizing = false
        onCanceled: root.winResizing = false
        opacity: hovered ? 0.50 : 0
    }
    ResizeButton{
        z: 10
        text:"↙️"
        font.pixelSize: fontUIx *2
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        onPressed:  {

            root.startSystemResize(Qt.BottomEdge | Qt.LeftEdge)
            root.winResizing = true
        }
        onReleased: root.winResizing = false
        onCanceled: root.winResizing = false
        opacity: hovered ? 0.50 : 0
    }
    ResizeButton{
        z: 10
        text:"🤚"
        visible: !viewMenus
        font.pixelSize: fontUIx *2
        anchors.top: parent.top
        anchors.right: parent.right
        onPressed: {
            root.startSystemMove()
        }
        // onReleased: text = "🤚"
        onDoubleClicked: toggleMenus()
        opacity: hovered ? 0.50 : 0
    }
    ResizeButton{
        z: 10
        text:"🤚"
        visible: !viewMenus && drawerShut
        font.pixelSize: fontUIx *2
        anchors.top: parent.top
        anchors.left: parent.left
        onPressed: {
            root.startSystemMove()
        }
        onDoubleClicked: toggleMenus()
        opacity: hovered ? 0.50 : 0
    }

}


