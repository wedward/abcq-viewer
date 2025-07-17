// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

import QtQuick3D

import RWatcher
import FModel
import prototype
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

            interval: 2000
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
    Action {

        text: "<table width='100%'><tr>" +
              "<td align='left'>" + "Colapse Folders" + "</td>" +
              "<td align='right'>" + shortcut + "</td>" +
              "</tr></table>"
        enabled: true //sidebar.currentTabIndex === 1
        onTriggered:  {
            fileSystemView.rootIndex = undefined
        }
        shortcut: "Ctrl+/"
    }

    menuBar: MyMenuBar {
        id: menuBar
        win: root
        // infoText: "TopBarText"
        visible: root.viewMenus
        font.pixelSize: fontUIx

        MyMenu {
            id: fileMenu

            property var temp

            Component{
                id: dummyLoader
                Shortcut{

                    enabled: false
                    sequence: {sequence= fileMenu.temp}

                }
            }

            function getShorty(s){
                fileMenu.temp = s
                let dummy = dummyLoader.createObject()
                let ret = dummy.nativeText
                dummy.destroy()
                return ret
            }
            fontUIx: root.fontUIx
            title: "File"


            Action {
                // text: "<table width='100%'><tr><td align='left'>Label</td><td align='right'>Value</td></tr></table>"

                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "New Window" + "</td>" +
                      "<td align='right'>" + fileMenu.getShorty(shortcut) + "</td>" +
                      "</tr></table>"
                onTriggered: newWindow()
                shortcut: StandardKey.New

            }

            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Previous Window" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: main.reopen()
                enabled: main.purgatory !== null
                shortcut: "Ctrl+Shift+N"
            }


            Action{

                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Refresh"+ "</td>" +
                      "<td align='right'>" + shortcut+ "</td>" +
                      "</tr></table>"
                onTriggered: reloadTimer.start()
                shortcut: "F5"

            }
            Action{
                property string substring: viewMenus ? "Hide":"Show"
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + substring + " Menus" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: toggleMenus()
                shortcut: "Escape"
            }
            Action{
                property string substring: drawerAjar ? "Show":"Hide"
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + substring + " Drawer" + "</td>" +
                      "<td align='right'>" + shortcut+ "</td>" +
                      "</tr></table>"
                onTriggered: toggleDrawer()
                shortcut: "Tab"

            }

            Action{

                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Increase Text"+ "</td>" +
                      "<td align='right'>" +shortcut+ "</td>" +
                      "</tr></table>"
                onTriggered: main.increaseScale()
                shortcut: "="

            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Decrease Text" +"</td>" +
                      "<td align='right'>" + shortcut+ "</td>" +
                      "</tr></table>"
                onTriggered: main.decreaseScale()
                shortcut: "-"

            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Reset Text"+ "</td>" +
                      "<td align='right'>" + shortcut+ "</td>" +
                      "</tr></table>"
                onTriggered: main.resetScale()
                shortcut: "Backspace"

            }

            Action{
                property string substring: filewatcher.listening ? "ON" : "OFF"
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Auto-reload " + substring + "</td>" +
                      "<td align='right'>" + shortcut+ "</td>" +
                      "</tr></table>"
                onTriggered: toggleWatcher()
                shortcut: "F2"

            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Reset Reload Interval" + "</td>" +
                      "<td align='right'>" + shortcut+ "</td>" +
                      "</tr></table>"
                onTriggered: main.resetIntervalMS()
                shortcut: "Ctrl+F2"

            }


            Action {
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Exit" + "</td>" +
                      "<td align='right'>" +"</td>" +
                      "</tr></table>"
                onTriggered: Qt.exit(0)
                shortcut: StandardKey.Quit
            }


        }
        MyMenu {
            id: cameraMenu
            fontUIx: root.fontUIx
            title: "Camera"

            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Top" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.top()
                // enabled: main.purgatory !== null
                shortcut: "1"
            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Bottom" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.bottom()
                // enabled: main.purgatory !== null
                shortcut: "2"
            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Right" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.right()
                // enabled: main.purgatory !== null
                shortcut: "3"
            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Left" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.left()
                // enabled: main.purgatory !== null
                shortcut: "4"
            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Front" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.front()
                // enabled: main.purgatory !== null
                shortcut: "5"
            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Back" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.back()
                // enabled: main.purgatory !== null
                shortcut: "6"
            }
            Action{
                property string substring: viewer.scn.activeCam === viewer.scn.camOrtho ? "Orthographic":"Perspective"
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "View: " + substring + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.swapCam()
                // enabled: main.purgatory !== null
                shortcut: "7"
            }
            Action{
                property string substring: viewer.scn.normsOn ? "Normals":"OFF"
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Debug: " + substring + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.toggleNorms()
                // enabled: main.purgatory !== null
                shortcut: "8"
            }
            Action{
                property string substring: viewer.scn.shadowQual ===Light.Hard ? "Hard":"Soft"
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Shadows: " + substring + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.toggleShadowQual()
                // enabled: main.purgatory !== null
                shortcut: "9"
            }
            Action{
                // property string substring: viewer.scn.shadowQual ===Light.Hard ? "Hard":"Soft"
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Reset Zoom" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.resetZoom()
                // enabled: main.purgatory !== null
                shortcut: "0"
            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Reset Z Dist." + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.resetZDist()
                // enabled: main.purgatory !== null
                shortcut: "Ctrl+0"
            }
        }
        MyMenu {
            fontUIx: root.fontUIx
            title: "Animation"

            Action{
                property string substring: viewer.scn.animRunning ? "Stop":"Start"
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + substring + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.toggleAnim()
                // enabled: main.purgatory !== null
                shortcut: "Space"
            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Increase Speed" + "</td>" +
                      "<td align='right'>" + shortcut  + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.increaseAnimSpeed(-0.1)
                // enabled: main.purgatory !== null
                shortcut: "."
            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Decrease Speed" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.increaseAnimSpeed(.1)
                // enabled: main.purgatory !== null
                shortcut: ","
            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Change Direction" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.changeAnimDir()
                // enabled: main.purgatory !== null
                shortcut: "m"
            }
            Action{
                text: "<table width='100%'><tr>" +
                      "<td align='left'>" + "Change Axis" + "</td>" +
                      "<td align='right'>" + shortcut + "</td>" +
                      "</tr></table>"
                onTriggered: viewer.scn.changeAnimAxis()
                // enabled: main.purgatory !== null
                shortcut: "n"
            }
        }
        MyMenu {
            fontUIx: root.fontUIx
            title: "Python"
            Action {
                property string substring: backend === "cpp" ?"Launch prototype.py" : "🐍 🐍 🐍 🐍 🐍"
                // property bool cpp: typeof appPath !== "undefined"
                text: "<table width='100%'><tr>" +
                      "<td align='center'>" + "🐍 "+ substring +" 🐍" + "</td>" +
                      "</tr></table>"
                
                shortcut: "Ctrl+Shift+F3"

                // check if running cpp/py
                enabled: backend === "cpp"
                onTriggered:  Qt.openUrlExternally(appPath+"/prototype.bat") 
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

                color: Theme.surface1

                Layout.fillHeight: true
                Layout.fillWidth: true

                StackLayout {
                    id: stack

                    anchors.fill: parent
                    currentIndex: sidebar.currentTabIndex

                    FileSystemView {
                        id: fileSystemView
                        color: Theme.surface1
                        onFileClicked: path => root.filePath = path
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


