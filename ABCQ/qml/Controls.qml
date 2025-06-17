import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import ABCQ

// This is the Control Center for changing application state.


Rectangle{
    id: root
    color: Colors.surface1

    property real fontM: win.main.fontM
    property real fontL: win.main.fontL
    property real heightM: win.main.heightM
    property real heightL: win.main.heightL

    property var scn
    property ApplicationWindow win


    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5
        //SPACER
        Item{
            Layout.preferredHeight: 0
            Layout.fillWidth: true

        }

        //0 Ortho
        RowLayout {
            spacing: 5
            Layout.preferredHeight: heightM

            ControlButton{
                text: "Top"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                onPressed: scn.top()
            }
            ControlButton{
                text: "Right"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                onPressed: scn.right()
            }
            ControlButton{
                text: "Front"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                onPressed: scn.front()
            }


        }

        //0.5 Ortho
        RowLayout {

            spacing: 5
            Layout.preferredHeight: heightM

            ControlButton{
                text: "Bottom"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                onPressed: scn.bottom()
            }
            ControlButton{
                text: "Left"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                onPressed: scn.left()
            }
            ControlButton{
                text: "Back"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                onPressed: scn.back()
            }
        }

        //SPACER
        Item{
            Layout.preferredHeight: 0
            Layout.fillWidth: true

        }


        //1 Cam
        RowLayout{
            spacing: 5
            Layout.preferredHeight: heightL

            ControlButton{
                text: scn.activeCam === scn.camOrtho ? "🎦 Ortho" : "🎦 Pers."
                fontSize: fontL
                Layout.fillWidth: true
                Layout.preferredHeight: heightL
                onPressed: scn.swapCam()

            }

            ControlButton{
                visible: scn.activeCam === scn.camPer
                text: "Z: " + Math.floor(100 * ( 1 / ( scn.longestDim / scn.camPerY ) - 1 ))
                fontSize: fontL
                Layout.fillWidth: true
                Layout.preferredHeight: heightL
                onDoubleClicked: scn.resetZDist()
                onDragged: (dx,dy) => {
                    scn.camPerY += dx
                    scn.camPerY = Math.max(scn.camPerY, scn.longestDim)
                }
                cursor: Qt.SizeHorCursor
            }

            ControlButton{
                text: "🔎 " + Math.floor(scn.mag*100).toString() + " %"
                fontSize: fontL
                Layout.fillWidth: true
                Layout.preferredHeight: heightL
                onDoubleClicked: scn.resetZoom()
                onDragged: (dx,dy) => scn.mag = scn.mag * Math.pow(1.5, dx/200)
                cursor: Qt.SizeHorCursor
            }
        }


        RowLayout{
            spacing: 5
            Layout.preferredHeight: heightM
            onWidthChanged: {
                if (width < 150) {
                    animDir.visible = false
                    animAxis.visible = false
                } else {
                    animDir.visible = true
                    animAxis.visible = true
                }
            }

            ControlButton{
                text: scn.animRunning ? "⏸️": "▶️"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                Layout.horizontalStretchFactor: 1
                Layout.preferredWidth: 40 + fontL
                Layout.maximumWidth: 40 + fontL
                onPressed: scn.toggleAnim()
            }
            ControlButton{
                id: animAxis
                text: {
                    if      (scn.animAxis === "Y") return "Z"
                    else if (scn.animAxis === "Z") return "Y"
                    else                           return "X"
                }
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                Layout.horizontalStretchFactor: 1
                Layout.preferredWidth: 0
                Layout.maximumWidth: 20 + fontL

                onPressed: {

                    var resume = scn.updateAnim()

                    scn.changeAnimAxis()
                    if (resume) scn.startAnim()
                }
            }
            ControlButton{
                id: animDir
                visible: width > 0
                text: scn.animDir===-1.0 ? "➕" : "➖"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                Layout.horizontalStretchFactor: 1
                Layout.preferredWidth: 0
                Layout.maximumWidth: 20 + fontL
                onPressed: {
                    var resume = scn.updateAnim()
                    scn.changeAnimDir()
                    if (resume) scn.startAnim()
                }
            }
            ControlButton{
                text: (scn.animSpeed * 10).toFixed(2) + " s"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                Layout.horizontalStretchFactor: 3
                Layout.preferredWidth: 30 + heightL

                cursor: Qt.SizeHorCursor

                // property bool resume: false

                onPressed: {
                    // resume = scn.updateAnim()
                }
                onDragged: (dx,dy) => {
                    scn.increaseAnimSpeed(dx/200)
                }
                onReleased: {
                    // if(resume){
                    //     scn.animRunning = true
                        // resume = false

                }
                onDoubleClicked: scn.resetAnimSpeed()

            }
        }

        //SPACER
        Item{
            Layout.preferredHeight: 0
            Layout.fillWidth: true

        }

        //2 DLight 1
        RowLayout{
            spacing:5
            Layout.preferredHeight: heightL

            ControlButton{
                text: "💡"
                fontSize: heightM
                Layout.fillWidth: true
                Layout.preferredHeight: heightL
                Layout.horizontalStretchFactor: 1
                Layout.preferredWidth: 50
                Layout.minimumWidth: 0
                Layout.maximumWidth: heightL * 1.5

                onDoubleClicked: scn.resetLightPan()

                onDragged: (dx,dy) => {

                   var p = Math.PI / 360
                   var x = -dx* p
                   var y = dy * p
                   var qh = Qt.quaternion( Math.cos(x/2),0,0,Math.sin(x/2))
                   var qv = Qt.quaternion (Math.cos(y/2),Math.sin(y/2),0,0)
                   var qr = qh.times(qv)
                   scn.lightRot = qr.times(scn.lightRot)


                           }

                cursor: Qt.SizeAllCursor
             }
            ControlButton{
                text: (scn.lightBright * 10).toFixed(0).toString() + " %"
                fontSize: fontL
                Layout.fillWidth: true
                Layout.preferredHeight: heightL
                Layout.horizontalStretchFactor: 1
                Layout.preferredWidth: 50
                Layout.minimumWidth: 0
                cursor: Qt.SizeHorCursor
                onDragged: (dx,dy) => scn.increaseLightBright(dx/20)
                onDoubleClicked: scn.lightBright = 5
            }
            ControlButton{
                text: (scn.lightSF).toFixed(0).toString() + " %"
                fontSize: fontL
                Layout.fillWidth: true
                Layout.preferredHeight: heightL
                Layout.horizontalStretchFactor: 1
                Layout.preferredWidth: 50
                Layout.minimumWidth: 0
                cursor: Qt.SizeHorCursor
                onDragged: (dx,dy) => scn.lightSF += dx/2
                onDoubleClicked: scn.lightSF = 50
            }
        }

        //2.5 DLight2
        RowLayout{
            spacing:5
            Layout.preferredHeight: heightL

            ControlButton{
                text: "💡"
                fontSize: heightM
                Layout.fillWidth: true
                Layout.preferredHeight: heightL
                Layout.horizontalStretchFactor: 1
                Layout.preferredWidth: 50
                Layout.minimumWidth: 0
                Layout.maximumWidth: heightL * 1.5

                onDoubleClicked: scn.resetLightPan2()

                onDragged: (dx,dy) => {

                   var p = Math.PI / 360
                   // var cos = Math.cos
                   // var sin = Math.sin
                   var x = -dx* p
                   var y = dy * p
                   var qh = Qt.quaternion( Math.cos(x/2),0,0,Math.sin(x/2))
                   var qv = Qt.quaternion (Math.cos(y/2),Math.sin(y/2),0,0)
                   var qr = qh.times(qv)
                   scn.lightRot2 = qr.times(scn.lightRot2)


                           }

                cursor: Qt.SizeAllCursor
             }
            ControlButton{
                text: (scn.lightBright2 * 10).toFixed(0).toString() + " %"
                fontSize: fontL
                Layout.fillWidth: true
                Layout.preferredHeight: heightL
                Layout.horizontalStretchFactor: 1
                Layout.preferredWidth: 50
                Layout.minimumWidth: 0
                cursor: Qt.SizeHorCursor
                onDragged: (dx,dy) => scn.increaseLightBright2(dx/20)
                onDoubleClicked: scn.lightBright2 = 5
            }
            ControlButton{
                text: (scn.lightSF2).toFixed(0).toString() + " %"
                fontSize: fontL
                Layout.fillWidth: true
                Layout.preferredHeight: heightL
                Layout.horizontalStretchFactor: 1
                Layout.preferredWidth: 50
                Layout.minimumWidth: 0
                cursor: Qt.SizeHorCursor
                onDragged: (dx,dy) => scn.lightSF2 += dx/2
                onDoubleClicked: scn.lightSF2 = 50
            }
        }

        //3 Debug
        RowLayout{
            spacing: 5
            Layout.preferredHeight: heightM

            ControlButton{
                text: scn.normsOn ? "Normals" : "Default"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                onPressed: scn.toggleNorms()
            }
            ControlButton{
                text: scn.shadowQualStr
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                onPressed: scn.toggleShadowQual()

            }
            ControlButton{
                text: "Bias: " + scn.shadowBias.toFixed(1).toString()
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                cursor: Qt.SizeHorCursor
                onDragged: (dx,dy) => scn.shadowBias += dx/20
                onDoubleClicked: scn.resetShadowBias()
            }
        }


        //BIG GAP
        Item{
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        //4 Window
        RowLayout{
            spacing: 5
            Layout.preferredHeight: heightM

            StackLayout{
                Layout.preferredHeight: heightM
                Layout.fillWidth: true
                Layout.fillHeight: false

                currentIndex: win.isMain ? 0 : 1

                ControlButton{
                    text: "New Window ↗️"
                    fontSize: fontM
                    Layout.fillWidth: true
                    Layout.preferredHeight: heightM
                    onPressed: win.main.newWindow()
                }

                ControlButton{
                    text: "👻: " + Math.floor(win.opac*100) + " %"
                    fontSize: fontM
                    Layout.fillWidth: true
                    Layout.preferredHeight: heightL
                    onDragged: (dx,dy) => win.increaseOpac(dx/200)
                    onDoubleClicked: win.resetOpac()
                    cursor: Qt.SizeHorCursor
                }
            }

            ControlButton{
                text: "👁️ " +Math.round(root.win.main.effectiveScale*100) + " %"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                onDragged: (dx,dy) => root.win.main.increaseScale(dx/400)
                cursor: Qt.SizeHorCursor
                onDoubleClicked: root.win.main.resetScale()
            }
        }

        //5 Watcher
        RowLayout{
            spacing:5
            visible: true
            Layout.preferredHeight: heightM
            onWidthChanged: {
                if (width <= 155){
                    ms.visible = false
                } else {
                    ms.visible = true
                }
            }

            ControlButton{
                property string prepend: win.listening ? "  ON: " : " OFF: "
                text: prepend + win.filePath
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                Layout.horizontalStretchFactor: 3
                Layout.preferredWidth: 150

                hAlign: Text.AlignLeft

                onPressed: { win.toggleWatcher()}

             }

            ControlButton{
                id: ms
                text: win.main.intervalMS + " ms"
                fontSize: fontM
                Layout.fillWidth: true
                Layout.preferredHeight: heightM
                Layout.horizontalStretchFactor: 1
                Layout.preferredWidth: 0
                Layout.maximumWidth: 30 + heightL
                onDragged: (dx,dy) => {
                   win.main.intervalMS += dx > 0 ? Math.ceil(dx) : Math.floor(dx)
                   win.main.intervalMS = Math.max(5,win.main.intervalMS)
                }
                cursor: Qt.SizeHorCursor

                onDoubleClicked: win.main.resetIntervalMS()
            }


        }

    }
}
